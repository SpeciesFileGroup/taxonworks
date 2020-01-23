import ajaxCall from 'helpers/ajaxCall'

const GetImage = (id) => {
  return ajaxCall('get', `/images/${id}.json`)
}

const CreateSledImages = (data) => {
  return ajaxCall('post', '/sled_images.json', data)
}

export {
  GetImage,
  CreateSledImages
}