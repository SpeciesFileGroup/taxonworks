import Vue from 'vue'
import VueResource from 'vue-resource'

Vue.use(VueResource)
Vue.http.headers.common['X-CSRF-Token'] = document.querySelector('meta[name="csrf-token"]').getAttribute('content')

const ajaxCall = function (type, url, data = null) {
  return new Promise(function (resolve, reject) {
    Vue.http[type](url, data).then(response => {
      return resolve(response.body)
    }, response => {
      handleError(response.body)
      return reject(response)
    })
  })
}

const handleError = function (json) {
  if (typeof json !== 'object') return
  let errors = Object.keys(json)
  let errorMessage = ''

  errors.forEach(function (item) {
    errorMessage += json[item].join('<br>')
  })

  TW.workbench.alert.create(errorMessage, 'error')
}

const CreateMatrix = function (data) {
  return ajaxCall('post', `/observation_matrices.json`, { observation_matrix: data })
}

const GetMatrixObservation = function(id) {
  return ajaxCall('get',`/observation_matrices/${id}.json`)
}

const GetMatrixObservationRows = function(id) {
  return ajaxCall('get',`/observation_matrices/${id}/observation_matrix_rows.json`)
}

const GetMatrixObservationColumns = function(id) {
  return ajaxCall('get',`/observation_matrices/${id}/observation_matrix_columns.json`)
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


export {
  CreateMatrix,
  CreateRowBatchLoad,
  CreateColumnBatchLoad,
  CreateRowItem,
  GetMatrixObservation,
  GetMatrixObservationRows,
  GetMatrixObservationColumns,
  GetMatrixColumnMetadata,
  GetMatrixRowMetadata,
  BatchRemoveKeyword,
  GetSmartSelector,
  RemoveRow,
  RemoveColumn
}
