import ajaxCall from 'helpers/ajaxCall'

const CreateObservation = (observation) => {
  return ajaxCall('post', '/observations.json', { observation: observation })
}

const GetObservationMatrix = (id) => {
  return ajaxCall('get', `/observation_matrices/${id}.json`)
}

const GetMatrixObservationColumns = function(id) {
  return ajaxCall('get',`/observation_matrices/${id}/observation_matrix_columns.json`)
}

const GetMatrixObservationRows = function(id) {
  return ajaxCall('get',`/observation_matrices/${id}/observation_matrix_rows.json`)
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

export {
  GetObservationMatrix,
  GetMatrixObservationColumns,
  GetMatrixObservationRows,
  GetObservation,
  CreateObservation,
  DestroyObservation,
  UpdateObservation
}