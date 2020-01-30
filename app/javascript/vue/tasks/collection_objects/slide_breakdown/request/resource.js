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

const CreateSledImage = (data) => {
  return ajaxCall('post', `/sled_images.json`, data)
}

const NukeSledImage = (id) => {
  return ajaxCall('delete', `/sled_images/${id}.json`, { nuke: 'nuke' })
}

const NavigationSled = (globalId) => {
  return ajaxCall('get', `/metadata/object_navigation/${encodeURIComponent(globalId)}`)
}

const Report = (id) => {
  return ajaxCall('get', `/collection_objects/report.json`, { params: { sled_image_id: id } })
}

export {
  GetImage,
  GetSledImage,
  UpdateSledImage,
  NukeSledImage,
  CreateSledImage,
  NavigationSled,
  Report
}