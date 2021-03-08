import ajaxCall from 'helpers/ajaxCall'
import IMatrixRowCoderRequest from './IMatrixRowCoderRequest'

function getJSON (url) {
  return new Promise((resolve, reject) => {
    ajaxCall('get', url).then(response => {
      resolve(response.body)
    }, (error) => {
      reject(error.body)
    })
  })
}

function postJSON (url, payload) {
  return new Promise((resolve, reject) => {
    ajaxCall('post', url, payload).then(response => {
      resolve(response.body)
    }, (error) => {
      reject(error.body)
    })
  })
}

function putJSON (url, payload) {
  return new Promise((resolve, reject) => {
    ajaxCall('patch', url, payload).then(response => {
      resolve(response.body)
    }, (error) => {
      reject(error.body)
    })
  })
}

function deleteResource (url) {
  return new Promise((resolve, reject) => {
    ajaxCall('delete', url).then(response => {
      resolve(response.body)
    }, (error) => {
      reject(error.body)
    })
  })
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

  getMatrixRow (rowId) {
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

  getUnits () {
    const url = this.buildGetUrl('/descriptors/units.json')
    return getJSON(url)
  }

  getConfidenceLevels () {
    const url = this.buildGetUrl('/confidence_levels.json')
    return getJSON(url)
  }
}
