import { SledImage } from '@/routes/endpoints'
import { RouteNames } from '@/routes/routes.js'
import { MutationNames } from '../mutations/mutations'
import SetParam from '@/helpers/setParam.js'
import makeSledImage from '../../const/sledImage'

export default ({ state, commit }) => {
  return SledImage.nuke(state.sled_image.id).then((response) => {
    const sled = makeSledImage()

    sled.image_id = state.image.id
    sled.metadata = state.sled_image.metadata

    commit(MutationNames.SetSledImage, sled)

    SetParam(RouteNames.GridDigitizer, 'sled_image_id', undefined, false, true)
  })
}
