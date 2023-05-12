import { COLLECTION_OBJECT_PROPERTIES } from 'shared/Filter/constants'

function parseDataAttributes(item) {
  try {
    return Object.fromEntries(
      item.data_attributes.map(({ predicate_name, value }) => [
        [predicate_name],
        value
      ])
    )
  } catch {}
}

export function listParser(list) {
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
      data_attributes: parseDataAttributes(item)
    }
  })
}
