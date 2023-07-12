import { chunkArray } from '@/helpers/arrays'
import { DataAttribute, Georeference } from '@/routes/endpoints'

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

function setCEWithGeoreferences(list, georeferences) {
  return list.map((item) => {
    const data = georeferences.filter(
      (georeference) =>
        georeference.collecting_event_id === item.collecting_event.id
    )

    return {
      ...item,
      georeferences: data
    }
  })
}

async function loadGeoreferences(list = []) {
  const CHUNK_ARRAY_SIZE = 40
  const idLists = chunkArray(
    list.map((item) => item.collecting_event.id),
    CHUNK_ARRAY_SIZE
  )

  const requests = idLists.map((ids) =>
    Georeference.where({ collecting_event_id: ids })
  )

  const georeferenceRequests = await Promise.all(requests)
  const georeferences = georeferenceRequests
    .map((response) => response.body)
    .flat()

  return setCEWithGeoreferences(list, georeferences)
}

export async function listParser(list, { parameters }) {
  const { extend, exclude, ...rest } = parameters
  const { body } = await DataAttribute.brief({
    collecting_event_query: {
      ...rest,
      paginate: true
    }
  })

  const newList = list.map((item) => {
    const identifiers = Array.isArray(item.identifiers)
      ? item.identifiers
      : [item.identifiers]

    return {
      id: item.id,
      global_id: item.global_id,
      collecting_event: {
        ...item,
        roles: (item?.collector_roles || [])
          .map((role) => role.person.cached)
          .join('; '),
        identifiers: identifiers.map((i) => i.cached).join('; ')
      },
      data_attributes: getDataAttributesFor(body, item.id)
    }
  })

  return await loadGeoreferences(newList)
}
