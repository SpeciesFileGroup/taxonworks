export default (state, { imageIds, key }) => {
  imageIds.forEach((imageId) => {
    state.settings.appliedByImage[imageId] = {
      ...state.settings.appliedByImage[imageId],
      [key]: true
    }
  })
}
