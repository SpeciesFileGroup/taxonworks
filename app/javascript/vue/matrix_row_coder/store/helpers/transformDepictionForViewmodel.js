const CharacterStateObjectName = 'CharacterState'

export default function transformDepiction (depictionData) {
  const depiction = {
    caption: depictionData.caption,
    normalSrc: depictionData.image.image_file_url,
    mediumSrc: depictionData.image.alternatives.medium.image_file_url,
    thumbSrc: depictionData.image.alternatives.thumb.image_file_url
  }

  if (depictionData.depiction_object_type === CharacterStateObjectName) { depiction.characterStateId = depictionData.depiction_object_id }

  return depiction
}
