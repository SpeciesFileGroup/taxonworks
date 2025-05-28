import { COLLECTION_OBJECT_PROPERTIES } from '@/shared/Filter/constants'
import { getDataAttributesFor } from '@/shared/Filter/utils'
import { DataAttribute } from '@/routes/endpoints'

function getTaxonDetermination(determinations) {
  if (determinations.length) {
    const [determination] = determinations.toSorted(
      (a, b) => a.position - b.position
    )

    return {
      ...determination,
      otu_name: determination?.otu?.name
    }
  }

  return []
}

function makeRowBind(dwc) {
  return dwc.rebuild_set
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
      id,
      global_id,
      collecting_event = {},
      container,
      container_item,
      current_repository = {},
      dwc_occurrence = {},
      identifiers = [],
      repository = {},
      taxon_determinations = []
    } = item

    return {
      id,
      global_id,
      collecting_event,
      collection_object,
      container: {
        ...container_item,
        ...container
      },
      current_repository,
      dwc_occurrence,
      repository,
      taxon_determinations: getTaxonDetermination(taxon_determinations),
      identifiers: {
        cached: identifiers.map((item) => item.cached).join(' | ')
      },
      data_attributes: getDataAttributesFor(body, item.id),
      ...makeRowBind(dwc_occurrence)
    }
  })
}
