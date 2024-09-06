function makeDataAttributeObjectHeaders(index) {
  return Object.assign({}, ...index)
}

export function getDataAttributesFor({ data, index }, objectId) {
  const list = data.filter(([, id]) => id === objectId)
  const headers = makeDataAttributeObjectHeaders(index)

  return Object.assign(
    {},
    ...list.map(([, , attrId, value]) => ({
      [headers[attrId]]: value
    }))
  )
}
