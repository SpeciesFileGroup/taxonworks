import imageAppliedStatus from '../../helpers/imageAppliedStatus'

export default (state) =>
  state.imagesCreated.every(
    (image) => !imageAppliedStatus(state, image.id).pending.length
  )
