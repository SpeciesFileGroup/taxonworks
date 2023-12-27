const copyObject = (obj) => JSON.parse(JSON.stringify(obj))

const copyObjectByProperties = (objSource, objProperties) => {
  const objKeys = Object.keys(objProperties)
  const newObj = Object.fromEntries(
    Object.entries(objSource).filter(([key]) => objKeys.includes(key))
  )

  return newObj
}

const copyObjectByArray = (objSource, arrProperties) => {
  const objKeys = arrProperties
  const newObj = Object.fromEntries(
    Object.entries(objSource).filter(([key]) => objKeys.includes(key))
  )

  return newObj
}

const isJSON = (str) => {
  try {
    return typeof str === 'object' || (JSON.parse(str) && !!str)
  } catch (e) {
    return false
  }
}

const isObject = (value) => typeof value === 'object' && value !== null

function removeEmptyProperties(object) {
  const obj = { ...object }

  for (const key in obj) {
    const value = obj[key]

    if (
      value === '' ||
      value === undefined ||
      (Array.isArray(value) && !value.length) ||
      (typeof value === 'object' && !Object.keys(value).length)
    ) {
      delete obj[key]
    }
  }

  return obj
}

const isDeepEqual = (object1, object2) => {
  const objKeys1 = Object.keys(object1)
  const objKeys2 = Object.keys(object2)

  if (objKeys1.length !== objKeys2.length) return false

  for (const key of objKeys1) {
    const value1 = object1[key]
    const value2 = object2[key]

    const isObjects = isObject(value1) && isObject(value2)

    if (
      (isObjects && !isDeepEqual(value1, value2)) ||
      (!isObjects && value1 !== value2)
    ) {
      return false
    }
  }
  return true
}

export {
  copyObject,
  copyObjectByArray,
  copyObjectByProperties,
  isJSON,
  isObject,
  removeEmptyProperties,
  isDeepEqual
}
