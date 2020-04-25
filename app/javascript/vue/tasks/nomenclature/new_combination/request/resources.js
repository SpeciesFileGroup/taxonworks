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
      return resolve(response.body)
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
  TW.workbench.alert.create(Object.values(json).join('<br>'), 'error')
}

const GetParse = function (taxon_name) {
  return new Promise(function (resolve, reject) {
    Vue.http.get(`/taxon_names/parse?query_string=${taxon_name}`, {
      before (request) {
        if (Vue.previousRequest) {
          Vue.previousRequest.abort()
        }
        Vue.previousRequest = request
      }

    }).then(response => {
      return resolve(response.body)
    })
  })
}

const GetLastCombinations = function () {
  return ajaxCall('get', `/combinations.json`)
}

const GetCombination = function (id) {
  return ajaxCall('get', `/combinations/${id}.json`)
}

const GetTaxonName = function(id) {
  return ajaxCall('get', `/taxon_names/${id}.json`)
}

const CreateCombination = function (combination) {
  return ajaxCall('post', `/combinations`, combination)
}

const UpdateCombination = function (id, combination) {
  return ajaxCall('patch', `/combinations/${id}.json`, combination)
}

const DestroyCombination = function (id) {
  return ajaxCall('delete', `/combinations/${id}.json`)
}

const CreatePlacement = function (id, taxon_name) {
  return ajaxCall('patch', `/taxon_names/${id}.json`, taxon_name)
}

export {
  GetParse,
  GetTaxonName,
  GetCombination,
  CreatePlacement,
  GetLastCombinations,
  UpdateCombination,
  CreateCombination,
  DestroyCombination
}
