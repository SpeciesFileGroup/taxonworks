export default (referenceObject, copyObject) => {
  let tmp = {}
  Object.keys(referenceObject).forEach(key => {
    tmp[key] = copyObject[key]
  })

  return Object.assign({}, tmp)
}