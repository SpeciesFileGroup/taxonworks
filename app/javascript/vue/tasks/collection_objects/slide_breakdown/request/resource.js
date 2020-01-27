import ajaxCall from 'helpers/ajaxCall'

const GetImage = (id) => {
  return ajaxCall('get', `/images/${id}.json`)
}

const GetSledImage = (id) => {
  return ajaxCall('get', `/sled_images/${id}.json`)
}

const UpdateSledImage = (id, data) => {
  return ajaxCall('patch', `/sled_images/${id}.json`, data)
}

export {
  GetImage,
  GetSledImage,
  UpdateSledImage
}