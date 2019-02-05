import { CreateDepiction } from '../../request/resources'
import { MutationNames } from '../mutations/mutations'

export default function({ state, commit }) {
  state.objectsForDepictions.forEach(object => {
    state.imagesCreated.forEach(item => {
      let data = {
        depiction_object_id: object.id,
        depiction_object_type: object.base_class,
        image_id: item.id
      }
      CreateDepiction(data).then(response => {
        commit(MutationNames.AddDepiction, response.body)
      })
    })
  })
}