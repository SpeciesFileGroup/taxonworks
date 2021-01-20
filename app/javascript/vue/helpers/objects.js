const copyObjectByProperties = (objSource, objProperties) => {
  const objKeys = Object.keys(objProperties)
  const newObj = Object.fromEntries(Object.entries(objSource).filter(([key]) => objKeys.includes(key)))

  return newObj
}

export {
  copyObjectByProperties
}
