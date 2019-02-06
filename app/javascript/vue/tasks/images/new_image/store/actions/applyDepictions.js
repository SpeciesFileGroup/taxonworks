import { CreateDepiction } from '../../request/resources'
import { MutationNames } from '../mutations/mutations'

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
        image_id: item.id
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
    })
  })

  Promise.all(promises).then(() => {
    state.settings.saving = false
    if(createdCount > 0)
      TW.workbench.alert.create(`Depiction(s) was successfully created.`, 'notice')
  })
}