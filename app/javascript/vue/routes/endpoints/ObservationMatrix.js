import baseCRUD from './base'
import AjaxCall from 'helpers/ajaxCall'

const controller = 'observation_matrices'
const permitParams = {
  observation_matrix: {
    name: String,
    otu_ids: Array
  }
}

export const ObservationMatrix = {
  ...baseCRUD(controller, permitParams),

  columns: (id) => AjaxCall('get', `/${controller}/${id}/observation_matrix_columns.json`),

  row: (params) => AjaxCall('get', `/${controller}/row.json`, { params }),

  rowLabels: (id, params) => AjaxCall('get', `/${controller}/${id}/row_labels`, { params }),

  rows: (id, params) => AjaxCall('get', `/${controller}/${id}/observation_matrix_rows.json`, { params }),

  otusUseInMatrix: (params) => AjaxCall('get', `/${controller}/otus_used_in_matrices.json`, { params })

}
