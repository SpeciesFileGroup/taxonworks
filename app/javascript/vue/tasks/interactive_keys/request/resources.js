import ajaxCall from 'helpers/ajaxCall'

const GetObservationMatrix = (id) => ajaxCall('get', `/observation_matrices/${id}.json`)

const GetMatrixObservationColumns = (id, params) => ajaxCall('get', `/observation_matrices/${id}/observation_matrix_columns.json`, { params: params })

export {
  GetObservationMatrix,
  GetMatrixObservationColumns
}
