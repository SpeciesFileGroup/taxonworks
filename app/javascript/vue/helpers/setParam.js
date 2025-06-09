import { isObject } from './objects.js'

function transformObjectToParams (params) {
  const urlParams = new URLSearchParams({})

  return objectToParams(urlParams, params)
}

function objectToParams (URLParams, objectParams) {
  const entries = Object.entries(objectParams)

  entries.forEach(([key, value]) => {
    if (value) {
      if (Array.isArray(value)) {
        value.forEach(item => {
          URLParams.append(`${key}[]`, item)
        })
      } else {
        URLParams.set(key, value)
      }
    } else {
      URLParams.delete(key)
    }
  })

  return URLParams
}

function areEqual (URLParams, objectParams, value) {
  return isObject(objectParams)
    ? Object.entries(objectParams).every(([param, paramValue]) => URLParams.get(param) == paramValue)
    : URLParams.get(objectParams) == value
}

export default (url, param, value = undefined, removeTextObject = false) => {
  let urlParams = new URLSearchParams(window.location.search)
  const sameValue = areEqual(urlParams, param, value)

  if (typeof param === 'object') {
    urlParams = objectToParams(urlParams, param)
  } else {
    if (value) {
      urlParams.set(param, value)
    } else {
      urlParams.delete(param)
    }
  }

  // TODO: temporary workaround for URLSearchParams adding an [object: Object]
  // value to your params when you have a[b][]=1&a[b][]=2 params.
  for (const [key, value] of urlParams) {
    if (value == '[object Object]') {
      urlParams.delete(key)
    }
  }

  const paramsString = urlParams.toString()
  const urlString = paramsString.length
    ? `${url}?${urlParams.toString()}`
    : url

  if (sameValue) {
    history.replaceState(null, null, urlString)
  } else {
    history.pushState(null, null, urlString)
  }
}

export {
  transformObjectToParams
}
