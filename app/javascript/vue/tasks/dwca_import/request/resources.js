import AjaxCall from 'helpers/ajaxCall'

const GetDataset = (id) => AjaxCall('get', `/import_datasets/${id}.json`)

const GetImports = () => AjaxCall('get', '/tasks/dwca_import/index.json')

const GetDatasetRecords = (id, params) => AjaxCall('get', `/import_datasets/${id}/dataset_records.json`, params)

const UpdateRow = (importId, rowId, data) => AjaxCall('patch', `/import_datasets/${importId}/dataset_records/${rowId}.json`, data)

const ImportRows = (datasetId, params) => AjaxCall('post', `/import_datasets/${datasetId}/import.json`, params)

export {
  GetDataset,
  GetImports,
  GetDatasetRecords,
  UpdateRow,
  ImportRows
}
