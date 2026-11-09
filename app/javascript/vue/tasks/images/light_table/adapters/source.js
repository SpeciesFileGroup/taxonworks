import { CONVERT_IMAGE_TYPES, DEPICTION, IMAGE } from '@/constants'

function imageSrc(image) {
  return CONVERT_IMAGE_TYPES.includes(image.content_type)
    ? image.as_png
    : image.image_file_url
}

export function imageToSource(
  image,
  { depictions = [], viewBox = null, clipPath = null } = {}
) {
  return {
    src: imageSrc(image),
    alt: image.image_original_filename || `Image ${image.id}`,
    mediaWidth: image.width,
    mediaHeight: image.height,
    viewBox,
    clipPath,
    meta: {
      objectType: IMAGE,
      objectId: image.id,
      object: image,
      depictions
    }
  }
}

export function depictionToSource(depiction) {
  return imageToSource(depiction.image, {
    depictions: [depiction],
    viewBox: depiction.svg_view_box || null,
    clipPath: depiction.svg_clip || null
  })
}

export function objectToSource(type, object) {
  return type === DEPICTION ? depictionToSource(object) : imageToSource(object)
}

export function getImage({ objectType, object }) {
  return objectType === DEPICTION ? object.image : object
}

export function getImageId(objectType, object) {
  return objectType === DEPICTION ? object.image_id : object.id
}

export function imageKey(imageId) {
  return `${IMAGE}:${imageId}`
}

export function getThumbUrl(image) {
  return image.alternatives.thumb.image_file_url
}
