function objectToParams (URLParams, objectParmas) {
  Object.keys(objectParmas).forEach(key => {
    if (objectParmas[key]) {
      URLParams.set(key, objectParmas[key])
    } else {
      URLParams.delete(key)
    }
  })
  return URLParams
}

export default function (url, param, value = undefined) {
  let urlParams = new URLSearchParams(window.location.search)

  if (typeof param === 'object') {
    urlParams = objectToParams(urlParams, param)
  } else {
    if (value) {
      urlParams.set(param, value)
    } else {
      urlParams.delete(param)
    }
  }
  const paramsString = urlParams.toString()

  history.pushState(null, null, (paramsString.length ? `${url}?${urlParams.toString()}` : url))
}
