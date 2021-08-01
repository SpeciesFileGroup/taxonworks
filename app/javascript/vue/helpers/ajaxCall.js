// use requestId to cancel previous request with the same Id
import Axios from 'axios'
import { capitalize } from './strings'

const REQUEST_TYPE = {
  Get: 'get',
  Patch: 'patch',
  Post: 'post',
  Put: 'put',
  Delete: 'delete'
}
const CancelToken = Axios.CancelToken
const previousTokenRequests = []
const axios = Axios.create({
  headers: {
    'Content-Type': 'application/json',
    Accept: 'application/json'
  }
})

const ajaxCall = (type, url, data = {}, config = {}) => {
  const cancelFunction = config.cancelRequest || data.cancelRequest
  const requestId = config.requestId || data.requestId
  axios.defaults.headers.common['X-CSRF-Token'] = document.querySelector('meta[name="csrf-token"]').getAttribute('content')

  if (requestId) {
    const source = CancelToken.source()
    const previousToken = previousTokenRequests[requestId]

    Object.assign(config, { cancelToken: source.token })

    if (previousToken) {
      previousToken.cancel()
    }

    previousTokenRequests[requestId] = source
  }

  if (cancelFunction) {
    const cancelToken = { cancelToken: new CancelToken(cancelFunction) }

    if (
      type === REQUEST_TYPE.Get ||
      type === REQUEST_TYPE.Delete) {
      Object.assign(data, cancelToken)
    } else {
      Object.assign(config, cancelToken)
    }

    delete config.cancelRequest
    delete data.cancelRequest
  }

  return new Promise((resolve, reject) => {
    axios[type](url, data, config).then(response => {
      response = setDataProperty(response)

      printDevelopmentResponse(response)
      resolve(response)
    }, error => {
      if (Axios.isCancel(error)) {
        reject(error)
      }

      printDevelopmentResponse(error.response)
      error.response = setDataProperty(error.response)

      switch (error.response.status) {
        case 404:
          break
        default:
          handleError(error.response.body)
      }

      reject(error.response)
    })
  })
}

const handleError = (json) => {
  if (typeof json !== 'object') return

  const removeTitleFor = ['base']

  TW.workbench.alert.create(Object.entries(json).map(([key, errors]) => `
    ${removeTitleFor.includes(key) ? '' : `<span data-icon="warning">${key}:</span>`}
      <ul>
        <li>${Array.isArray(errors) ? errors.map(line => capitalize(line)).join('</li><li>') : errors}</li>
      </ul>`
  ).join(''), 'error')
}

const setDataProperty = (response) => {
  response.body = response.data
  delete response.data

  return response
}

const printDevelopmentResponse = (response) => {
  if (process.env.NODE_ENV !== 'production') {
    console.log(response)
  }
}

export default ajaxCall
