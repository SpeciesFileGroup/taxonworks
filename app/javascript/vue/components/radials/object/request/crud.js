import Vue from 'vue'
import VueResource from 'vue-resource'
import { capitalize } from 'helpers/strings.js'

Vue.use(VueResource)

const ajaxCall = function (type, url, data) {
  return new Promise(function (resolve, reject) {
    Vue.http.headers.common['X-CSRF-Token'] = document.querySelector('meta[name="csrf-token"]').getAttribute('content')
    Vue.http[type](url, data).then(response => {
      eventEmitRadialAnnotator(type, data)
      return resolve(response)
    }, response => {
      handleError(response.body)
      return reject(response)
    })
  })
}

const handleError = function (json) {
  if (typeof json !== 'object') return
  TW.workbench.alert.create(Object.keys(json).map(key => {
    return `<span data-icon="warning">${key}:</span> <ul><li>${json[key].map(line => capitalize(line)).join('</li><li>')}</li></ul>`
  }).join(''), 'error')
}

const eventEmitRadialAnnotator = function (typeEvent, object) {
  var event = new CustomEvent(`radial:${typeEvent}`, {
    detail: {
      object: object,
    }
  });
  document.dispatchEvent(event);
}

const create = function (url, data) {
  return ajaxCall('post', url, data)
}

const update = function (url, data) {
  return ajaxCall('patch', url, data)
}

const destroy = function (url, data) {
  return ajaxCall('delete', url, data)
}

const getList = function (url, data = {}) {
  return ajaxCall('get', url, data)
}

const vueCrud = {
  methods: {
    create: create,
    update: update,
    destroy: destroy,
    getList: getList
  }
}

export default vueCrud
