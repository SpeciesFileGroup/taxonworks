import { CreateDepiction } from '../../request/resources'
import { MutationNames } from '../mutations/mutations'

function validateSqed(sqed) {
  return (sqed.boundary_color &&
    sqed.boundary_finder &&
    sqed.layout)
}

export default function({ state, commit }) {
  let alreadyCreated = undefined
  let promises = []
  let createdCount = 0

  state.settings.saving = true

  state.objectsForDepictions.forEach(object => {
    state.imagesCreated.forEach(item => {
      let data = {
        depiction_object_id: object.id,
        depiction_object_type: object.base_class,
        image_id: item.id,
        sqed_depiction_attributes: (validateSqed(state.sqed) && object.base_class == 'CollectionObject') ? state.sqed : undefined
      }

      console.log(data)

      alreadyCreated = state.depictionsCreated.find(depiction => {
        return depiction.depiction_object_id == object.id && depiction.depiction_object_type == object.base_class && depiction.image_id == item.id
      })
      
      if(!alreadyCreated) {
        promises.push(CreateDepiction(data).then(response => {
          createdCount++
          commit(MutationNames.AddDepiction, response.body)
        }))
      }
    })
  })

  Promise.all(promises).then(() => {
    state.settings.saving = false
    if(createdCount > 0)
      TW.workbench.alert.create(`Depiction(s) was successfully created.`, 'notice')
  })
}