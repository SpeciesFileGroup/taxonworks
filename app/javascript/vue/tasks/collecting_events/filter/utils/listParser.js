import { chunkArray } from 'helpers/arrays'
import { DataAttribute, Georeference } from 'routes/endpoints'

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
  return list.map((ce) => {
    const data = georeferences.filter(
      (item) => item.collecting_event_id === ce.id
    )

    return {
      ...ce,
      georeferences: data,
      georeferencesCount: data.length
    }
  })
}

function parseStartDate(ce) {
  return [ce.start_date_day, ce.start_date_month, ce.start_date_year]
    .filter((date) => date)
    .join('/')
}

function parseEndDate(ce) {
  return [ce.end_date_day, ce.end_date_month, ce.end_date_year]
    .filter((date) => date)
    .join('/')
}

async function loadGeoreferences(list = []) {
  const CHUNK_ARRAY_SIZE = 40
  const idLists = chunkArray(
    list.map((ce) => ce.id),
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
      ...item,
      roles: (item?.collector_roles || [])
        .map((role) => role.person.cached)
        .join('; '),
      identifiers: identifiers.map((i) => i.cached).join('; '),
      start_date: parseStartDate(item),
      end_date: parseEndDate(item),
      data_attributes: getDataAttributesFor(body, item.id)
    }
  })

  return await loadGeoreferences(newList)
}
