import AjaxCall from 'helpers/ajaxCall'

const GetImport = (id) => {
  return AjaxCall('get', `/tasks/dwca_import/${id}/workbench`)
}

const UpdateRow = (rowId) => {
  return AjaxCall('patch', `/tasks/dwca_import/{id}/workbench/core_table/${rowId}`)
}

const ImportRows = (rowsId) => {
  return AjaxCall('patch', `/tasks/dwca_import/${rowsId}/workbench/core_table/import`, { row_ids: rowsId })
}

export {
  GetImport,
  UpdateRow,
  ImportRows
}