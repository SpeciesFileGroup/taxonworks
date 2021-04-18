// use requestId to cancel previous request with the same Id
import Axios from 'axios'
import { capitalize } from './strings'

const axios = Axios.create({
  headers: {
    'Content-Type': 'application/json',
    Accept: 'application/json'
  }
})

const CancelToken = Axios.CancelToken
const previousTokenRequests = []

const ajaxCall = function (type, url, data = {}, config = {}) {
  const requestId = config.requestId || data.requestId
  axios.defaults.headers.common['X-CSRF-Token'] = document.querySelector('meta[name="csrf-token"]').getAttribute('content')

  if (requestId) {
    const source = CancelToken.source()
    Object.assign(config, { cancelToken: source.token })

    if (previousTokenRequests[requestId]) { previousTokenRequests[requestId].cancel() }
    previousTokenRequests[requestId] = source
  }

  return new Promise(function (resolve, reject) {
    axios[type](url, data, config).then(response => {
      response.body = response.data
      delete response.data
      if (process.env.NODE_ENV !== 'production') {
        console.log(response)
      }
      return resolve(response)
    }, error => {
      if (process.env.NODE_ENV !== 'production') {
        console.log(error.response)
      }
      error.response.body = error.response.data
      delete error.response.data

      switch (error.response.status) {
        case 404:
          break
        default:
          handleError(error.response.body)
      }
      return reject(error.response)
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

export default ajaxCall
