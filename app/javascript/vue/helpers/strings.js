function capitalize (string) {
  return string.charAt(0).toUpperCase() + string.substring(1)
}

function shorten (str, maxLen, separator = ' ') {
  if (str.length <= maxLen) return str
  return `${str.substr(0, str.lastIndexOf(separator, maxLen))} ...`
}

export {
  capitalize,
  shorten
}
