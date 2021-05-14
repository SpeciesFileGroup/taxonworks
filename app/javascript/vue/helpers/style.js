function convertToUnit (str, unit = 'px') {
  if (!Number(str) && !str) {
    return undefined
  } else if (isNaN(str)) {
    return String(str)
  } else {
    return `${Number(str)}${unit}`
  }
}

export {
  convertToUnit
}
