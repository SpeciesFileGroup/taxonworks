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

const GetMatrixObservationColumnItems = function(id) {
  return ajaxCall('get',`/observation_matrices/${id}/observation_matrix_column_items.json`)
}

const GetMatrixObservationRowItems = function(id) {
  return ajaxCall('get',`/observation_matrices/${id}/observation_matrix_row_items.json`)
}

const GetMatrixObservationRows = function(id) {
  return ajaxCall('get',`/observation_matrices/${id}/observation_matrix_rows.json`)
}

const GetMatrixObservationColumns = function(id) {
  return ajaxCall('get',`/observation_matrices/${id}/observation_matrix_columns.json`)
}

const CreateRowItem = function(data) {
  return ajaxCall('post',`/matrix_row_items.json`, data)
}

export {
  CreateMatrix,
  CreateRowItem,
  GetMatrixObservation,
}
