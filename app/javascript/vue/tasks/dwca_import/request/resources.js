import AjaxCall from 'helpers/ajaxCall'

const DestroyDataset = (id) => AjaxCall('delete', `/import_datasets/${id}.json`)

const GetDataset = (id) => AjaxCall('get', `/import_datasets/${id}.json`)

const GetImports = () => AjaxCall('get', '/tasks/dwca_import/index.json')

const GetDatasetRecords = (id, params) => AjaxCall('get', `/import_datasets/${id}/dataset_records.json`, params)

const GetNamespace = (id) => AjaxCall('get', `/namespaces/${id}.json`)

const UpdateRow = (importId, rowId, data) => AjaxCall('patch', `/import_datasets/${importId}/dataset_records/${rowId}.json`, data)

const UpdateCatalogueNumber = (data) => AjaxCall('post', '/tasks/dwca_import/update_catalog_number_namespace', data)

const UpdateImportSettings = (data) => AjaxCall('post', '/tasks/dwca_import/set_import_settings', data)

const UpdateColumnField = (importId, params) => AjaxCall('patch', `/import_datasets/${importId}/dataset_records/set_field_value`, params)

const ImportRows = (datasetId, params) => AjaxCall('post', `/import_datasets/${datasetId}/import.json`, params)

const StopImport = (datasetId, params) => AjaxCall('post', `/import_datasets/${datasetId}/stop_import.json`, params)

export {
  DestroyDataset,
  GetDataset,
  GetImports,
  GetDatasetRecords,
  GetNamespace,
  ImportRows,
  StopImport,
  UpdateRow,
  UpdateCatalogueNumber,
  UpdateColumnField,
  UpdateImportSettings
}
