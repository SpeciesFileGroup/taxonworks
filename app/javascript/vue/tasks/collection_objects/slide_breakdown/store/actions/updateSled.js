import { UpdateSledImage, CreateSledImage } from '../../request/resource'
import { MutationNames } from '../mutations/mutations'

export default ({ state, commit }) => {
  return new Promise((resolve, reject) => {
    let co = state.collection_object
    const identifier = state.identifier
    const depiction = state.depiction

    if (identifier.namespace_id && identifier.identifier && state.sled_image.step_identifier_on) {
      co.identifiers_attributes = [identifier]
    }

    const data = {
      sled_image: state.sled_image,
      collection_object: co,
      depiction: depiction
    }

    if (state.sled_image.id) {
      UpdateSledImage(state.sled_image.id, data).then(response => {
        commit(MutationNames.SetSledImage, response.body)
        resolve(true)
      }, () => {
        reject(false)
      })
    } else {
      data.sled_image.image_id = state.image.id
      CreateSledImage(data).then(response => {
        commit(MutationNames.SetSledImage, response.body)
        resolve(true)
      }, () => {
        reject(false)
      })
    }
  })
}
