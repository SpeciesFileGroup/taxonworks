import { NukeSledImage } from '../../request/resource'
import { MutationNames } from '../mutations/mutations'
import SledImage from '../../const/sledImage'

export default ({ state, commit }) => {
  NukeSledImage(state.sled_image.id).then(response => {
    let sled = SledImage()
    sled.image_id = state.image.id
    sled.metadata = state.sled_image.metadata
    commit(MutationNames.SetSledImage, sled)
  })
}
