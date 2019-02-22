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

const GetDepictions = function (id) {
  return ajaxCall('get', `/otus/${id}/depictions.json`)
}

const GetNotes = function (id) {
  return ajaxCall('get', `/otus/${id}/notes.json`)
}

const GetTags = function (id) {
  return ajaxCall('get', `/otus/${id}/tags.json`)
}

const GetCitations = function (id) {
  return ajaxCall('get', `/otus/${id}/citations.json`)
}

const GetConfidences = function (id) {
  return ajaxCall('get', `/otus/${id}/confidences.json`)
}

const GetIdentifiers = function (id) {
  return ajaxCall('get', `/otus/${id}/identifiers.json`)
}

const GetDataAttributes = function (id) {
  return ajaxCall('get', `/otus/${id}/data_attributes.json`)
}

const GetContent = function (id) {
  return ajaxCall('get', `/contents/filter.json?otu_id=${id}`, { params: { most_recent_updates: 100 } })
}

const GetAssertedDistributions = function (id) {
  return ajaxCall('get', `/asserted_distributions?otu_id=${id}`)
}

const GetBiologicalAssociations = function (globalId) {
  return ajaxCall('get', `/biological_associations?any_global_id=${globalId}`)
}

export {
  GetOtu,
  GetDepictions,
  GetContent,
  GetAssertedDistributions,
  GetBiologicalAssociations,
  GetNotes,
  GetTags,
  GetCitations,
  GetDataAttributes,
  GetConfidences,
  GetIdentifiers
}