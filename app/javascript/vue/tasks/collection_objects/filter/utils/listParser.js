import { COLLECTION_OBJECT_PROPERTIES } from '@/shared/Filter/constants'
import { DataAttribute } from '@/routes/endpoints'
import { flattenObject } from '@/helpers'

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
  const { extend, exclude, ...rest } = parameters
  const { body } = await DataAttribute.brief({
    collection_object_query: {
      ...rest,
      paginate: true
    }
  })

  return list.map((item) => {
    const collection_object = Object.assign(
      {},
      ...COLLECTION_OBJECT_PROPERTIES.map((property) => ({
        [property]: item[property]
      }))
    )

    const {
      current_repository,
      repository,
      collecting_event,
      taxon_determinations,
      dwc_occurrence,
      identifiers,
      id,
      global_id
    } = item

    return {
      id,
      global_id,
      collection_object,
      current_repository,
      repository,
      collecting_event,
      taxon_determinations: taxon_determinations.map((item) =>
        flattenObject(item)
      ),
      dwc_occurrence,
      identifiers,
      data_attributes: getDataAttributesFor(body, item.id)
    }
  })
}
