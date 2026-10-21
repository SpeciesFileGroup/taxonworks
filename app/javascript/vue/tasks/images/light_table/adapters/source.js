import { DEPICTION, IMAGE } from '@/constants'

const CONVERT_IMAGE_TYPES = ['image/tiff', 'image/heic']

function imageSrc(image) {
  return CONVERT_IMAGE_TYPES.includes(image.content_type)
    ? image.as_png
    : image.image_file_url
}

export function depictionToSource(depiction) {
  const { image } = depiction

  return {
    src: imageSrc(image),
    alt:
      depiction.caption ||
      depiction.figure_label ||
      `Depiction ${depiction.id}`,
    mediaWidth: image.width,
    mediaHeight: image.height,
    viewBox: depiction.svg_view_box || null,
    clipPath: depiction.svg_clip || null,
    meta: {
      objectType: DEPICTION,
      objectId: depiction.id,
      object: depiction
    }
  }
}

export function imageToSource(image) {
  return {
    src: imageSrc(image),
    alt: image.image_original_filename || `Image ${image.id}`,
    mediaWidth: image.width,
    mediaHeight: image.height,
    meta: {
      objectType: IMAGE,
      objectId: image.id,
      object: image
    }
  }
}

export function objectToSource(type, object) {
  return type === DEPICTION ? depictionToSource(object) : imageToSource(object)
}
