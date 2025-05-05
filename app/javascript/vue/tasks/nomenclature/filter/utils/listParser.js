import { DataAttribute } from '@/routes/endpoints'

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
    taxon_name_query: {
      ...rest,
      paginate: true
    }
  })
  return list.map((item) => ({
    id: item.id,
    global_id: item.global_id,
    cached_html: `<a title="${item.cached}" href="/tasks/nomenclature/browse?taxon_name_id=${item.id}">${item.cached_html}</a>`,
    cached_author_year: item.cached_author_year,
    original_combination: item.original_combination,
    cached_is_valid: item.cached_is_valid ? 'Yes' : 'No',
    valid_name: item.valid_name?.cached_html,
    rank: item.rank,
    parent: item?.parent
      ? `<a title="${item.parent.object_label}" href="/tasks/nomenclature/browse?taxon_name_id=${item.parent.id}">${item.parent.object_label}</a>`
      : '',
    data_attributes: getDataAttributesFor(body, item.id)
  }))
}
