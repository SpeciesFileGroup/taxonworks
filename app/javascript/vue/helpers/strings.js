function capitalize(str = '') {
  if (typeof str !== 'string') {
    return str
  }

  return str.charAt(0).toUpperCase() + str.substring(1)
}

function shorten(str, maxLen, separator = ' ') {
  if (str.length <= maxLen) return str
  return `${str.substr(0, str.lastIndexOf(separator, maxLen))} ...`
}

function toSnakeCase(string) {
  return string
    .replace(/\s+/g, '_')
    .replace(/[A-Z]/g, (letter) => `_${letter.toLowerCase()}`)
    .replace(/-+/g, '_')
    .replace(/_+/g, '_')
    .replace(/^_/, '')
    .replace(/_$/, '')
    .toLowerCase()
}

function toPascalCase(str) {
  const words = str.replace(/([a-z])([A-Z])/g, '$1 $2').split(/[_-\s]+/)
  const pascalCaseStr = words
    .map((word) => word.charAt(0).toUpperCase() + word.slice(1).toLowerCase())
    .join('')

  return pascalCaseStr
}

function replaceAt(index, string, newString) {
  return index > -1
    ? string.substr(0, index) +
        newString +
        string.substr(index + newString.length)
    : string
}

function stringInline(text) {
  return text.replace(/\s+|\n|\r/g, ' ').trim()
}

function humanize(text = '') {
  if (typeof text !== 'string') {
    return text
  }

  return text
    .replace(/^[\s_]+|[\s_]+$/g, '')
    .replace(/[_\s]+/g, ' ')
    .replace(/^[a-z]/, (m) => m.toUpperCase())
}

function isEmpty(stringVar) {
  return stringVar == null || stringVar === ''
}

export {
  capitalize,
  shorten,
  toSnakeCase,
  replaceAt,
  stringInline,
  humanize,
  isEmpty,
  toPascalCase
}
