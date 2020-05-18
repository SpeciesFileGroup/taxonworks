import Vue from 'vue'
import VueResource from 'vue-resource'

Vue.use(VueResource)

const ajaxCall = function (type, url, data = null) {
  Vue.http.headers.common['X-CSRF-Token'] = document.querySelector('meta[name="csrf-token"]').getAttribute('content')
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

const CreateObservationMatrixColumn = (data) => {
  return ajaxCall('post', '/observation_matrix_column_items.json', { observation_matrix_column_item: data })
}

const CreateDescriptor = function (data) {
  return ajaxCall('post', `/descriptors.json`, { descriptor: data })
}

const UpdateDescriptor = function (data) {
  return ajaxCall('patch', `/descriptors/${data.id}.json`, { descriptor: data })
}

const DeleteDescriptor = function (id) {
  return ajaxCall('delete', `/descriptors/${id}.json`)
}

const LoadDescriptor = function (id) {
  return ajaxCall('get', `/descriptors/${id}.json`)
}

const GetUnits = function() {
  return ajaxCall('get','/descriptors/units')
}

const GetSequenceSmartSelector = () => {
  return ajaxCall('get', '/sequences/select_options')
}

const GetSequence = (id) => {
  return ajaxCall('get', `/sequences/${id}.json`)
}

const GetMatrix = (id) => {
  return ajaxCall('get', `/observation_matrices/${id}.json`)
}

export {
  CreateDescriptor,
  DeleteDescriptor,
  UpdateDescriptor,
  LoadDescriptor,
  GetUnits,
  GetSequenceSmartSelector,
  GetSequence,
  CreateObservationMatrixColumn,
  GetMatrix
}
