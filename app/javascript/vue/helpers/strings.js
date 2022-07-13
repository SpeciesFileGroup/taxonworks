function capitalize (str = '') {
  if (typeof str !== 'string') {
    return str
  }

  return str.charAt(0).toUpperCase() + str.substring(1)
}

function shorten (str, maxLen, separator = ' ') {
  if (str.length <= maxLen) return str
  return `${str.substr(0, str.lastIndexOf(separator, maxLen))} ...`
}

function toSnakeCase (string) {
  return string.replace(/\.?([A-Z])/g, (x, y) => `_${y.toLowerCase()}`).replace(/^_/, '')
}

function replaceAt (index, string, newString) {
  return index > -1
    ? string.substr(0, index) + newString + string.substr(index + newString.length)
    : string
}

function stringInline (text) {
  return text.replace(/\s+|\n|\r/g, ' ').trim()
}

function humanize (text = '') {
  if (typeof text !== 'string') {
    return text
  }

  return text
    .replace(/^[\s_]+|[\s_]+$/g, '')
    .replace(/[_\s]+/g, ' ')
    .replace(/^[a-z]/, m => m.toUpperCase())
}

export {
  capitalize,
  shorten,
  toSnakeCase,
  replaceAt,
  stringInline,
  humanize
}
