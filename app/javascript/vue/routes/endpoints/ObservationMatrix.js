import baseCRUD from './base'
import AjaxCall from '@/helpers/ajaxCall'

const controller = 'observation_matrices'
const permitParams = {
  observation_matrix: {
    name: String,
    otu_id: Number,
    is_public: Boolean
  }
}

export const ObservationMatrix = {
  ...baseCRUD(controller, permitParams),

  columns: (id) =>
    AjaxCall('get', `/${controller}/${id}/observation_matrix_columns.json`),

  objectsByColumnId: (id) =>
    AjaxCall('get', `/${controller}/column.json`, {
      params: { observation_matrix_column_id: id }
    }),

  row: (params) => AjaxCall('get', `/${controller}/row.json`, { params }),

  rowLabels: (id, params) =>
    AjaxCall('get', `/${controller}/${id}/row_labels`, { params }),

  rows: (id, params) =>
    AjaxCall('get', `/${controller}/${id}/observation_matrix_rows.json`, {
      params
    }),

  otusUseInMatrix: (params) =>
    AjaxCall('get', `/${controller}/otus_used_in_matrices.json`, { params }),

  addBatch: (params) => AjaxCall('post', `/${controller}/batch_add`, params),

  createBatch: (params) =>
    AjaxCall('post', `/${controller}/batch_create`, params),

  previewNexus: (params) =>
    AjaxCall('get', `/${controller}/nexus_data.json`, { params }),

  initiateImportFromNexus: (params) =>
    AjaxCall('post', `/${controller}/import_from_nexus.json`, params)
}
