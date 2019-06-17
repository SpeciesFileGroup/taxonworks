import ajaxCall from 'helpers/ajaxCall'

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

export {
  GetObservationMatrix,
  GetMatrixObservationColumns,
  GetMatrixObservationRows,
  GetObservation
}