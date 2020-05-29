import Vue from 'vue'
import VueResource from 'vue-resource'

Vue.use(VueResource)

const ajaxCall = function (type, url, data = null) {
  Vue.http.headers.common['X-CSRF-Token'] = document.querySelector('meta[name="csrf-token"]').getAttribute('content')
  return new Promise(function (resolve, reject) {
    Vue.http[type](url, data).then(response => {
      if (process.env.NODE_ENV !== 'production') {
        console.log(response)
      }
      return resolve(response)
    }, response => {
      if (process.env.NODE_ENV !== 'production') {
        console.log(response)
      }
      if(response.status != 404)
        handleError(response.body)
      return reject(response)
    })
  })
}

const handleError = function (json) {
  if (typeof json !== 'object') return
  TW.workbench.alert.create(Object.keys(json).map(key => {
    return `<span data-icon="warning">${key}</span>: <ul><li>${json[key].join('</li><li>')}</li></ul>`
  }).join(), 'error')
}

export default ajaxCall
