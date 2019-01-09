import Vue from 'vue'
import VueResource from 'vue-resource'

Vue.use(VueResource)


const ajaxCall = function (type, url, data = null) {
  Vue.http.headers.common['X-CSRF-Token'] = document.querySelector('meta[name="csrf-token"]').getAttribute('content')
  return new Promise(function (resolve, reject) {
    Vue.http[type](url, data).then(response => {
      console.log(response)
      return resolve(response.body)
    }, response => {
      console.log(response)
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

const GetLabels = function () {
  return ajaxCall('get', '/labels')
}

const UpdateLabel = function (label) {
  return ajaxCall('patch', `/labels/${label.id}.json`, { label: label })
}

const CreateLabel = function (label) {
  return ajaxCall('post', `/labels.json`, { label: label })
}

const RemoveLabel = function (id) {
  return ajaxCall('delete', `/labels/${id}.json`)
}

export {
  GetLabels,
  CreateLabel,
  UpdateLabel,
  RemoveLabel
}