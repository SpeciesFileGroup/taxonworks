function isAttributeSet({ people, license }) {
  return Object.values(people).some((arr) => arr.length) || license
}

export default (state) => {
  const { applied } = state.settings
  const {
    people,
    tagsForImage,
    objectsForDepictions,
    license,
    depiction,
    imagesCreated,
    pixelsToCentimeter
  } = state

  if (!imagesCreated.length) {
    return true
  }

  if (!applied.attribution && isAttributeSet({ people, license })) {
    return false
  }

  if (!applied.tags && tagsForImage.length) {
    return false
  }

  if (!applied.source && state.source) {
    return false
  }

  if (!applied.pixel && pixelsToCentimeter) {
    return false
  }

  if (
    !applied.depiction &&
    (objectsForDepictions.length || depiction.caption.length)
  ) {
    return false
  }

  return true
}
