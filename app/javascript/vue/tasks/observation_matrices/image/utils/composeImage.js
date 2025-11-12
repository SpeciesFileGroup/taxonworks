export default (id, { image, citations }) => {
  return {
    id: id,
    global_id: image?.global_id,
    image_file_url: image.original_png,
    width: image.width,
    height: image.height,
    content_type: image.content_type,
    citations,
    alternatives: {
      medium: {
        image_file_url: image.alternatives.medium.image_file_url
      },
      thumb: {
        image_file_url: image.alternatives.thumb.image_file_url
      }
    }
  }
}
