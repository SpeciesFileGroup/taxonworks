import qs from 'qs'

const URLParamsToJSON = function (query) {
  if (query.indexOf('?') < 0) return {}
  query = query.substring(query.indexOf('?') + 1)

  return qs.parse(query, {
    arrayFormat: 'bracket',
    arrayLimit: 5000,
    decoder(str, decoder, charset) {
      const strWithoutPlus = str.replace(/\+/g, ' ')
      if (charset === 'iso-8859-1') {
        return strWithoutPlus.replace(/%[0-9a-f]{2}/gi, unescape)
      }

      if (/^(\d+|\d*\.\d+)$/.test(str)) {
        return parseFloat(str)
      }

      const keywords = {
        true: true,
        false: false,
        null: null,
        undefined
      }
      if (str in keywords) {
        return keywords[str]
      }

      try {
        return decodeURIComponent(strWithoutPlus)
      } catch (e) {
        return strWithoutPlus
      }
    }
  })
}

export { URLParamsToJSON }
