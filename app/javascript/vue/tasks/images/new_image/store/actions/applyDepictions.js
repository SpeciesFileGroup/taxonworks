import { CreateDepiction, UpdateDepiction, CreateCollectionObject } from '../../request/resources'
import { MutationNames } from '../mutations/mutations'
import validateSqed from '../../helpers/validateSqed'

export default function({ state, commit }) {
  let alreadyCreated = undefined
  let promises = []
  let createdCount = 0

  state.settings.saving = true
  if(state.newCOForSqed) {
    state.imagesCreated.forEach(item => {
      promises.push(CreateCollectionObject({ total: 1 }).then(response => {
        let data = {
          depiction_object_id: response.body.id,
          depiction_object_type: response.body.base_class,
          image_id: item.id,
          sqed_depiction_attributes: (validateSqed(state.sqed) ? state.sqed : undefined)
        }
        createdCount++
        CreateDepiction(data).then(response => {
          commit(MutationNames.AddDepiction, response.body)
        })
      }))
    })
  }
  else {
    state.objectsForDepictions.forEach(object => {
      state.imagesCreated.forEach(item => {
        let data = {
          depiction_object_id: object.id,
          depiction_object_type: object.base_class,
          image_id: item.id,
          sqed_depiction_attributes: (validateSqed(state.sqed) && object.base_class == 'CollectionObject') ? state.sqed : undefined
        }

        alreadyCreated = state.depictionsCreated.find(depiction => {
          return depiction.depiction_object_id == object.id && depiction.depiction_object_type == object.base_class && depiction.image_id == item.id
        })
        
        if(!alreadyCreated) {
          promises.push(CreateDepiction(data).then(response => {
            createdCount++
            commit(MutationNames.AddDepiction, response.body)
          }))
        }
        else {
          data.id = alreadyCreated.id
          if(data.sqed_depiction_attributes && alreadyCreated.hasOwnProperty('sqed_depiction') && alreadyCreated.sqed_depiction.id) {
            data.sqed_depiction_attributes.id = alreadyCreated.sqed_depiction.id
          }
          promises.push(UpdateDepiction(data).then(response => {
            commit(MutationNames.AddDepiction, response.body)
          }))
        }
      })
    })
  }

  Promise.all(promises).then(() => {
    state.settings.saving = false
    if(createdCount > 0)
      TW.workbench.alert.create(`Depiction(s) was successfully created.`, 'notice')
  })
}