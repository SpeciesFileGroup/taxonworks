import { getDataAttributesFor } from '@/shared/Filter/utils'
import { DataAttribute } from '@/routes/endpoints'

function getTaxonDetermination(determinations) {
  return determinations.length
    ? determinations.toSorted((a, b) => a.position - b.position)[0]
    : []
}

function makeRowBind(dwc) {
  return dwc?.rebuild_set
    ? {
        _bind: {
          class: 'row-dwc-reindex-pending',
          title: 'DwcOccurrence re-index is pending.'
        }
      }
    : {}
}

export async function listParser(list, { parameters }) {
  const { extend, exclude, ...rest } = parameters
  const { body } = await DataAttribute.brief({
    field_occurrence_query: {
      ...rest,
      paginate: true
    }
  })

  return list.map((item) => ({
    id: item.id,
    global_id: item.global_id,
    label: item.object_tag,
    field_occurrence: {
      id: item.id,
      is_absent: item.is_absent ? 'Yes' : 'No',
      total: item.total
    },
    collecting_event: item.collecting_event,
    identifiers: item.identifiers,
    taxon_determinations: getTaxonDetermination(item.taxon_determinations),
    dwc_occurrence: item.dwc_occurrence,
    data_attributes: getDataAttributesFor(body, item.id),
    ...makeRowBind(item.dwc_occurrence)
  }))
}
