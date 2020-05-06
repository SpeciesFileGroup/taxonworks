import AjaxCall from 'helpers/ajaxCall'

const GetDataset = (id) => {
  return AjaxCall('get', `/import_datasets/${id}.json`)
}

const GetDatasetRecords = (id, params) => {
  return AjaxCall('get', `/import_datasets/${id}/dataset_records.json`, { params: params })
}

const UpdateRow = (importId, rowId, data) => {
  return AjaxCall('patch', `/import_datasets/${importId}/dataset_records/${rowId}.json`, data)
}

const ImportRows = (rowsId) => {
  return AjaxCall('patch', `/tasks/dwca_import/${rowsId}/workbench/core_table/import`, { row_ids: rowsId })
}

export {
  GetDataset,
  GetDatasetRecords,
  UpdateRow,
  ImportRows
}