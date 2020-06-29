const convertType = (value) => {
  if (value === 'undefined') return undefined
  try {
    return JSON.parse(value)
  } catch (e) {
    return value
  }
}

export {
  convertType
}
