import { convertType } from '../types'

const URLParamsToJSON = (url) => {
  const urlObject = new URL(url)
  const uri = decodeURI(urlObject.search.substr(1))

  if (!uri.length) return {}

  var chunks = uri.split('&')
  var params = Object()

  for (var i = 0; i < chunks.length; i++) {
    var chunk = chunks[i].split('=')
    if (chunk[0].search('\\[\\]') !== -1) {
      chunk[0] = chunk[0].replace(/\[\]$/, '')
      if (typeof params[chunk[0]] === 'undefined') {
        params[chunk[0]] = [convertType(chunk[1])]
      } else {
        params[chunk[0]].push(convertType(chunk[1]))
      }
    } else {
      params[chunk[0]] = convertType(chunk[1])
    }
  }
  return params
}

export {
  URLParamsToJSON
}
