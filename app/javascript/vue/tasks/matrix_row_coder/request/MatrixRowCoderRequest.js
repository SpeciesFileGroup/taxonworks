import Vue from 'vue'
import VueResource from 'vue-resource'
import IMatrixRowCoderRequest from './IMatrixRowCoderRequest'

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


function getJSON (url) {
  return ajaxCall('get', url)
}

function postJSON (url, payload) {
  return ajaxCall('post', url, payload)
}

function putJSON (url, payload) {
  return ajaxCall('patch', url, payload)
}

function deleteResource (url) {
  return ajaxCall('delete', url)
}

export default class MatrixRowCoderRequest extends IMatrixRowCoderRequest {
  constructor () {
    super()
    this.getObservationQueue = Promise.resolve({})
  }

  setApi ({apiBase, apiParams}) {
    this.apiBase = apiBase
    this.apiParams = {}
//    this.apiParams = {apiParams}
  }

  buildGetUrl (url, extraParams = {}) {
    return `${this.apiBase}${url}${MatrixRowCoderRequest.stringifyApiParams(Object.assign({}, this.apiParams, extraParams))}`
  }

  static stringifyApiParams (object) {
    return Object.keys(object).reduce((accumulated, property, currentIndex) => {
      return `${accumulated}${getPropertyPrefix(currentIndex)}${property}=${object[property]}`
    }, '')

    function getPropertyPrefix (index) {
      if (index === 0) { return '?' } else { return '&' }
    }
  }

  getMatrixRow (rowId, globalId) {
    const extraParams = {
      observation_matrix_row_id: rowId
    }
    const url = this.buildGetUrl(`/observation_matrices/row.json`, extraParams)
    return getJSON(url)
      .then(data => {
        console.log(`getMatrixRow:`, data)
        return data
      })
  }

  getObservations (globalId, descriptorId) {
    const extraParams = {
      observation_object_global_id: globalId,
      descriptor_id: descriptorId
    }
    const url = this.buildGetUrl(`/observations.json`, extraParams)
    this.getObservationQueue = this.getObservationQueue.then(_ => {
      return getJSON(url)
        .then(data => {
          console.log(`Observations for ${descriptorId}:`, data)
          return data
        })
    })
    return this.getObservationQueue
  }

  updateObservation (observationId, payload) {
    const url = `${this.apiBase}/observations/${observationId}.json${MatrixRowCoderRequest.stringifyApiParams(this.apiParams)}`
    return putJSON(url, payload)
  }

  createClone (payload) {
    const url = `${this.apiBase}/tasks/observation_matrices/observation_matrix_hub/copy_observations.json`
    return postJSON(url, Object.assign(payload, this.apiParams))
  }

  createObservation (payload) {
    const url = `${this.apiBase}/observations.json`
    console.log(Object.assign(payload, this.apiParams))
    return postJSON(url, Object.assign(payload, this.apiParams))
  }

  removeObservation (observationId) {
    const url = `${this.apiBase}/observations/${observationId}.json${MatrixRowCoderRequest.stringifyApiParams(this.apiParams)}`
    return deleteResource(url)
  }

  removeAllObservationsRow (rowId) {
    const url = `${this.apiBase}/observations/destroy_row.json?observation_matrix_row_id=${rowId}${MatrixRowCoderRequest.stringifyApiParams(this.apiParams)}`
    return deleteResource(url)
  }

  getDescriptorNotes (descriptorId) {
    const url = this.buildGetUrl(`/descriptors/${descriptorId}/notes.json`)
    return getJSON(url)
  }

  getDescriptorDepictions (descriptorId) {
    const url = this.buildGetUrl(`/descriptors/${descriptorId}/depictions.json`)
    return getJSON(url)
  }

  getObservationNotes (observationId) {
    const url = this.buildGetUrl(`/observations/${observationId}/notes.json`)
    return getJSON(url)
  }

  getObservationDepictions (observationId) {
    const url = this.buildGetUrl(`/observations/${observationId}/depictions.json`)
    return getJSON(url)
  }

  getObservationConfidences (observationId) {
    const url = this.buildGetUrl(`/observations/${observationId}/confidences.json`)
    return getJSON(url)
  }

  getObservationCitations (observationId) {
    const url = this.buildGetUrl(`/observations/${observationId}/citations.json`)
    return getJSON(url)
  }

  getConfidenceLevels () {
    const url = this.buildGetUrl(`/confidence_levels.json`)
    return getJSON(url)
  }
}
