import ajaxCall from 'helpers/ajaxCall'

const CreateObservationMatrixColumn = (data) => {
  return ajaxCall('post', '/observation_matrix_column_items.json', { observation_matrix_column_item: data })
}

const CreateDescriptor = function (data) {
  return ajaxCall('post', '/descriptors.json', { descriptor: data })
}

const UpdateDescriptor = function (data) {
  return ajaxCall('patch', `/descriptors/${data.id}.json`, { descriptor: data })
}

const DeleteDescriptor = function (id) {
  return ajaxCall('delete', `/descriptors/${id}.json`)
}

const LoadDescriptor = function (id) {
  return ajaxCall('get', `/descriptors/${id}.json`)
}

const GetUnits = function() {
  return ajaxCall('get','/descriptors/units')
}

const GetMatrix = (id) => {
  return ajaxCall('get', `/observation_matrices/${id}.json`)
}

export {
  CreateDescriptor,
  DeleteDescriptor,
  UpdateDescriptor,
  LoadDescriptor,
  GetUnits,
  CreateObservationMatrixColumn,
  GetMatrix
}
