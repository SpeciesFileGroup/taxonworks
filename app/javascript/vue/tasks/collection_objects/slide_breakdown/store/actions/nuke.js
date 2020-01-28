import { NukeSledImage } from '../../request/resource'
import { MutationNames } from '../mutations/mutations'
import SledImage from '../../const/sledImage'

export default ({ state, commit }) => {
  NukeSledImage(state.image.sled_image_id).then(response => {
    let sled = SledImage()
    sled.image_id = state.image.id
    console.log(sled)
    commit(MutationNames.SetSledImage, sled)
  })
}
