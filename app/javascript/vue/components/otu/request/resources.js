import Vue from 'vue'
import VueResource from 'vue-resource'

Vue.use(VueResource)

const ajaxCall = function (type, url, data = null, options = null) {
  return new Promise(function (resolve, reject) {
    Vue.http.headers.common['X-CSRF-Token'] = document.querySelector('meta[name="csrf-token"]').getAttribute('content')
    Vue.http[type](url, data, options).then(response => {
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
    if (Array.isArray(json[item])) {
      errorMessage += json[item].join('<br>')
    } else {
      errorMessage += json[item]
    }
  })

  TW.workbench.alert.create(errorMessage, 'error')
}

const GetOtus = function (id) {
  return ajaxCall('get', `/taxon_names/${id}/otus.json`, { headers: {
      'Cache-Control': 'no-cache'
    }
  })
}

const CreateOtu = function(id) {
  return ajaxCall('post', `/otus`, { otu: { taxon_name_id: id } })
}

export {
  GetOtus,
  CreateOtu
}