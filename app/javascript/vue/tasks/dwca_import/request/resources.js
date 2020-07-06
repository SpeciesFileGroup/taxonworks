import AjaxCall from 'helpers/ajaxCall'

const GetDataset = (id) => {
  return AjaxCall('get', `/import_datasets/${id}.json`)
}

const GetDatasetRecords = (id, params) => {
  return AjaxCall('get', `/import_datasets/${id}/dataset_records.json`, params)
}

const UpdateRow = (importId, rowId, data) => {
  return AjaxCall('patch', `/import_datasets/${importId}/dataset_records/${rowId}.json`, data)
}

const ImportRows = (datasetId, params) => {
  return AjaxCall('post', `/import_datasets/${datasetId}/import.json`, params)
}

export {
  GetDataset,
  GetDatasetRecords,
  UpdateRow,
  ImportRows
}
