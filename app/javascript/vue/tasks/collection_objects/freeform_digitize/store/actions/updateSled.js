import { MutationNames } from '../mutations/mutations'
import { SledImage } from 'routes/endpoints'

export default ({ state, commit }) => {
  const co = { ...state.collection_object }
  const identifier = state.identifier
  const depiction = state.depiction

  if (
    identifier.namespace_id &&
    identifier.identifier &&
    state.sled_image.step_identifier_on) {
    co.identifiers_attributes = [identifier]
  }

  const payload = {
    sled_image: state.sled_image,
    collection_object: co,
    depiction
  }

  const request = state.sled_image.id
    ? SledImage.update(state.sled_image.id, payload)
    : SledImage.create(payload)

  request.then(({ body }) => {
    commit(MutationNames.SetSledImage, body)
  })

  return request
}
