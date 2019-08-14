import ajaxCall from 'helpers/ajaxCall'

const UpdateDepiction = (id, data) => {
  return ajaxCall('patch', `/depictions/${id}.json`, data)
}

export {
  UpdateDepiction
}