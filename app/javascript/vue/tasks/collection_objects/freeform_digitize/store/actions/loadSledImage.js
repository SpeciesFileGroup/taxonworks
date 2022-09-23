import { SledImage, Image } from 'routes/endpoints'
import SetParam from 'helpers/setParam.js'
import { MutationNames } from '../mutations/mutations'

export default ({ commit, state }, sledId) => {
  SledImage.find(sledId).then(({ body }) => {
    SetParam('/tasks/collection_objects/freeform_digitize', 'sled_image_id', sledId)

    commit(MutationNames.SetSledImage, body)
    Image.find(body.image_id).then(response => {
      state.image = response.body
    })
  })
}
