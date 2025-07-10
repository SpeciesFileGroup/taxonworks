import Axios from 'axios'
import { capitalize } from './strings'
import { getCSRFToken } from './user'

const REQUEST_TYPE = {
  Get: 'get',
  Patch: 'patch',
  Post: 'post',
  Put: 'put',
  Delete: 'delete'
}

const axios = Axios.create({
  headers: {
    'Content-Type': 'application/json',
    Accept: 'application/json'
  }
})

axios.interceptors.response.use(
  function (response) {
    return setDataProperty(response)
  },
  function (error) {
    return Promise.reject(error)
  }
)

async function ajaxCall(type, url, data = {}, config = {}) {
  const CSRFToken = getCSRFToken()
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

  const request = axios[type](url, data, config)

  request
    .then((response) => {
      printDevelopmentResponse(response)
    })
    .catch((error) => {
      if (!Axios.isCancel(error)) {
        error.response = setDataProperty(error.response)
        printDevelopmentResponse(error.response)

        switch (error.response.status) {
          case 404:
            break
          default:
            handleError(error.response.body)
        }
      }
    })

  return request
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
        : `<span><span data-icon="warning"></span>${key}:</span>`
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
