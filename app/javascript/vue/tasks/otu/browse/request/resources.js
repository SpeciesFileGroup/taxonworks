import Vue from 'vue'
import VueResource from 'vue-resource'
import APIConfig from '../config/api'

Vue.use(VueResource)

const ajaxCall = function (type, url, data = null) {
  Vue.http.headers.common['X-CSRF-Token'] = document.querySelector('meta[name="csrf-token"]').getAttribute('content')
  return new Promise(function (resolve, reject) {
    let urlCompose = `${APIConfig.apiURL}${url}`

    Vue.http[type](urlCompose, Object.assign((data == null ? {} : data), APIConfig.apiParams)).then(response => {
      return resolve(response)
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

const GetOtu = function (id) {
  return ajaxCall('get', `/otus/${id}.json`)
}

export {
  GetOtu
}