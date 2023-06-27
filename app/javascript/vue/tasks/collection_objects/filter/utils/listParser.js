import { COLLECTION_OBJECT_PROPERTIES } from 'shared/Filter/constants'
import { DataAttribute } from 'routes/endpoints'

function makeDataAttributeObjectHeaders(data) {
  return Object.assign({}, ...data.index)
}

function getDataAttributesFor(data, objectId) {
  const list = data.data.filter(([id]) => id === objectId)
  const headers = makeDataAttributeObjectHeaders(data)

  return Object.assign(
    {},
    ...list.map(([id, attrId, value]) => ({
      [headers[attrId]]: value
    }))
  )
}

export async function listParser(list, { parameters }) {
  const { extend, ...rest } = parameters
  const { body } = await DataAttribute.brief({
    collection_object_query: {
      ...rest,
      pagination: true
    }
  })

  return list.map((item) => {
    const baseAttributes = Object.assign(
      {},
      ...COLLECTION_OBJECT_PROPERTIES.map((property) => ({
        [property]: item[property]
      }))
    )

    return {
      ...item,
      collection_object: baseAttributes,
      data_attributes: getDataAttributesFor(body, item.id)
    }
  })
}
