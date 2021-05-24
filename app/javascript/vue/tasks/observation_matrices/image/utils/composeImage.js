export default (id, image) => {
  return {
    id: id,
    global_id: image.global_id,
    image_file_url: image.original_url,
    width: image.width,
    height: image.height,
    content_type: image.image_file_content_type,
    citations: [],
    alternatives: {
      medium: {
        image_file_url: image.medium_url
      },
      thumb: {
        image_file_url: image.thumb_url
      }
    }
  }
}
