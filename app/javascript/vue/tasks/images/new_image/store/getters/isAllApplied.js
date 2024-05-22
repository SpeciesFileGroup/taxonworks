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

  return (
    !imagesCreated.length ||
    !(
      (!applied.attribution && isAttributeSet({ people, license })) ||
      (!applied.tags && tagsForImage.length) ||
      (!applied.source && state.source) ||
      (!applied.pixel && pixelsToCentimeter) ||
      (!applied.depiction &&
        (objectsForDepictions.length || depiction.caption.length))
    )
  )
}
