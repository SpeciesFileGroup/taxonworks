import ajaxCall from 'helpers/ajaxCall'

const GetDepictions = function (id) {
  return ajaxCall('get', `/collection_objects/${id}/depictions.json`)
}

const UpdateDepiction = function (id, data) {
  return ajaxCall('patch', `/depictions/${id}.json`, data)
}

const DestroyDepiction = function (id) {
  return ajaxCall('delete', `/depictions/${id}.json`)
}

export {
  GetDepictions,
  UpdateDepiction,
  DestroyDepiction
}