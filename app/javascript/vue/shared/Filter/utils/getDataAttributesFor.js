function makeDataAttributeObjectHeaders(index) {
  return Object.assign({}, ...index)
}

export function getDataAttributesFor({ data, index }, objectId) {
  const list = data.filter(([, id]) => id === objectId)
  const headers = makeDataAttributeObjectHeaders(index)

  return Object.assign(
    Object.fromEntries(Object.values(headers).map((key) => [key, ''])),
    ...list
      .filter(([, , attrId]) => headers[attrId])
      .map(([, , attrId, value]) => ({
        [headers[attrId]]: value
      }))
  )
}
