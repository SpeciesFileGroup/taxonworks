export default (str, separator) => {
  separator = typeof separator === 'undefined' ? ' ' : separator

  return str.replace(/([a-z\d])([A-Z])/g, '$1' + separator + '$2')
  .replace(/([A-Z]+)([A-Z][a-z\d]+)/g, '$1' + separator + '$2')
  .toLowerCase()
}