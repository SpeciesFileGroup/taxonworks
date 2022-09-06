const copyObject = obj => JSON.parse(JSON.stringify(obj))

const copyObjectByProperties = (objSource, objProperties) => {
  const objKeys = Object.keys(objProperties)
  const newObj = Object.fromEntries(Object.entries(objSource).filter(([key]) => objKeys.includes(key)))

  return newObj
}

const isJSON = (str) => {
  try {
    return (typeof str === 'object' || (JSON.parse(str) && !!str))
  } catch (e) {
    return false
  }
}

const isObject = (value) => typeof value === 'object' && value !== null

const removeEmptyProperties = object => {
  const keys = Object.keys(object)
  keys.forEach(key => {
    if (object[key] === '' || object[key] === undefined || (Array.isArray(object[key]) && !object[key].length)) {
      delete object[key]
    }
  })
  return object
}

export {
  copyObject,
  copyObjectByProperties,
  isJSON,
  isObject,
  removeEmptyProperties
}
