import baseCRUD from './base'
import AjaxCall from 'helpers/ajaxCall'

const controller = 'observation_matrices'
const permitParams = {
  observation_matrix: {
    name: String
  }
}

export const ObservationMatrix = {
  ...baseCRUD(controller, permitParams),

  columns: (id) => AjaxCall('get', `/${controller}/${id}/observation_matrix_columns.json`),

  rows: (id, params) => AjaxCall('get', `/${controller}/${id}/observation_matrix_rows.json`, { params })
}
