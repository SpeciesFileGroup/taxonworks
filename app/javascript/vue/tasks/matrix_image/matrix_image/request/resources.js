import ajaxCall from 'helpers/ajaxCall'

const CreateObservation = (observation) => {
  return ajaxCall('post', '/observations.json', { observation: observation })
}

const CreateRow = (data) => {
  return ajaxCall('post', '/observation_matrix_row_items', { observation_matrix_row_item: data })
}

const CreateColumn = (data) => {
  return ajaxCall('post', '/observation_matrix_column_items', { observation_matrix_column_item: data })
}

const CreateDescriptor = (data) => {
  return ajaxCall('post', '/descriptors', { descriptor: data })
}

const GetOtu = (id) => {
  return ajaxCall('get', `/otus/${id}`)
}

const GetCollectionObject = (id) => {
  return ajaxCall('get', `/collection_objects/${id}`)
}

const GetDescriptor = (id) => {
  return ajaxCall('get', `/descriptors/${id}`)
}

const GetObservationMatrix = (id) => {
  return ajaxCall('get', `/observation_matrices/${id}.json`)
}

const GetMatrixObservationColumns = (id) => {
  return ajaxCall('get', `/observation_matrices/${id}/observation_matrix_columns.json`)
}

const GetMatrixObservationRows = (id, data) => {
  return ajaxCall('get', `/observation_matrices/${id}/observation_matrix_rows.json`, data)
}

const GetObservation = (globalId, descriptorId) => {
  return ajaxCall('get', `/observations.json?observation_object_global_id=${globalId}&descriptor_id=${descriptorId}`)
}

const DestroyObservation = (id) => {
  return ajaxCall('delete', `/observations/${id}.json`)
}

const UpdateObservation = (observation) => {
  return ajaxCall('patch', `/observations/${observation.id}.json`, { observation: observation })
}

const UpdateDepiction = (depiction) => {
  return ajaxCall('patch', `/depictions/${depiction.id}.json`, { depiction: depiction })
}

const DestroyDepiction = (id) => {
  return ajaxCall('delete', `/depictions/${id}.json`)
}

export {
  GetObservationMatrix,
  GetMatrixObservationColumns,
  GetMatrixObservationRows,
  GetObservation,
  GetOtu,
  GetCollectionObject,
  GetDescriptor,
  CreateDescriptor,
  CreateObservation,
  CreateColumn,
  CreateRow,
  DestroyObservation,
  DestroyDepiction,
  UpdateObservation,
  UpdateDepiction
}