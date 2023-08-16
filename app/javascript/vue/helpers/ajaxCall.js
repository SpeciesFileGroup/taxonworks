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
  const CSRFToken = document
    .querySelector('meta[name="csrf-token"]')
    .getAttribute('content')
  const defaultHeaders = { 'X-CSRF-Token': CSRFToken }

  if (type === REQUEST_TYPE.Get || type === REQUEST_TYPE.Delete) {
    data = {
      headers: defaultHeaders,
      ...data
    }
  } else {
    config = {
      headers: defaultHeaders,
      ...config
    }
  }

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

    if (type === REQUEST_TYPE.Get || type === REQUEST_TYPE.Delete) {
      Object.assign(data, cancelToken)
    } else {
      Object.assign(config, cancelToken)
    }

    delete config.cancelRequest
    delete data.cancelRequest
  }

  return new Promise((resolve, reject) => {
    axios[type](url, data, config)
      .then((response) => {
        response = setDataProperty(response)
        printDevelopmentResponse(response)

        resolve(response)
      })
      .catch((error) => {
        if (Axios.isCancel(error)) {
          return reject(error)
        }

        error.response = setDataProperty(error.response)
        printDevelopmentResponse(error.response)

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

const handleError = (error) => {
  if (typeof error === 'object') {
    TW.workbench.alert.create(createErrorList(error), 'error')
  } else {
    TW.workbench.alert.create(error, 'error')
  }
}

function createErrorList(error) {
  const removeTitleFor = ['base']

  return Object.entries(error)
    .map(
      ([key, errors]) => `
    ${
      removeTitleFor.includes(key)
        ? ''
        : `<span data-icon="warning">${key}:</span>`
    }
      <ul>
        <li>${
          Array.isArray(errors)
            ? errors.map((line) => capitalize(line)).join('</li><li>')
            : errors
        }</li>
      </ul>`
    )
    .join('')
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
