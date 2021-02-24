import ajaxCall from 'helpers/ajaxCall.js'

const GetObservationMatrices = () => {
  return ajaxCall('get', '/observation_matrices.json')
}

const CreateMatrix = function (data) {
  return ajaxCall('post', `/observation_matrices.json`, { observation_matrix: data })
}

const UpdateMatrix = function (id, data) {
  return ajaxCall('patch', `/observation_matrices/${id}.json`, { observation_matrix: data })
}

const GetMatrixObservation = function(id) {
  return ajaxCall('get',`/observation_matrices/${id}.json`, { per: 500 })
}

const GetMatrixObservationRows = function (id, params = undefined) {
  return ajaxCall('get', `/observation_matrices/${id}/observation_matrix_rows.json`, { params: params })
}

const GetMatrixObservationRowsDynamic = function (id) {
  return new Promise((resolve, reject) => {
    let promises = []
    promises.push(ajaxCall('get',`/observation_matrices/${id}/observation_matrix_row_items.json?type=ObservationMatrixRowItem::Dynamic::Tag`))
    promises.push(ajaxCall('get',`/observation_matrices/${id}/observation_matrix_row_items.json?type=ObservationMatrixRowItem::Dynamic::TaxonName`))

    Promise.all(promises).then((response) => {
      return resolve(response[0].body.concat(response[1].body))
    })
  })
}

const GetMatrixObservationColumns = function(id, params) {
  return ajaxCall('get', `/observation_matrices/${id}/observation_matrix_columns.json`, { params: params })
}

const GetMatrixObservationColumnsDynamic = function(id) {
  return ajaxCall('get',`/observation_matrices/${id}/observation_matrix_column_items.json?type=ObservationMatrixColumnItem::Dynamic::Tag`)
}

const GetMatrixColumnMetadata = function() {
  return ajaxCall('get', `/tasks/observation_matrices/new_matrix/observation_matrix_column_item_metadata`)
}

const GetMatrixRowMetadata = function() {
  return ajaxCall('get', `/tasks/observation_matrices/new_matrix/observation_matrix_row_item_metadata`)
}

const CreateRowItem = function(data) {
  return ajaxCall('post',`/observation_matrix_row_items.json`, data)
}

const CreateColumnItem = function(data) {
  return ajaxCall('post',`/observation_matrix_column_items.json`, data)
}

const CreateRowBatchLoad = function (params) {
  return ajaxCall('post', '/observation_matrix_row_items/batch_create', params)
}

const CreateColumnBatchLoad = function (params) {
  return ajaxCall('post', '/observation_matrix_column_items/batch_create', params)
}

const BatchRemoveKeyword = function (id, type) {
  return ajaxCall('post', `/tags/batch_remove?keyword_id=${id}&klass=${type}`)
}

const RemoveRow = function(id) {
  return ajaxCall('delete', `/observation_matrix_row_items/${id}.json`)
}

const RemoveColumn = function(id) {
  return ajaxCall('delete', `/observation_matrix_column_items/${id}.json`)
}

const GetSmartSelector = function(type) {
  return ajaxCall('get', `/${type}/select_options?klass=ObservationMatrix`)
}

const SortRows = function(ids) {
  return ajaxCall('patch', `/observation_matrix_rows/sort`, { ids: ids })
}

const SortColumns = function(ids) {
  return ajaxCall('patch', `/observation_matrix_columns/sort`, { ids: ids })
}

export {
  CreateMatrix,
  CreateRowBatchLoad,
  CreateColumnBatchLoad,
  CreateRowItem,
  CreateColumnItem,
  GetMatrixObservation,
  GetMatrixObservationRows,
  GetMatrixObservationRowsDynamic,
  GetMatrixObservationColumns,
  GetMatrixObservationColumnsDynamic,
  GetMatrixColumnMetadata,
  GetObservationMatrices,
  GetMatrixRowMetadata,
  BatchRemoveKeyword,
  GetSmartSelector,
  UpdateMatrix,
  RemoveRow,
  RemoveColumn,
  SortColumns,
  SortRows
}
