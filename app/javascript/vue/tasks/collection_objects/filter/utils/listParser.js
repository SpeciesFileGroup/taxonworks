import { COLLECTION_OBJECT_PROPERTIES } from '@/shared/Filter/constants'
import { getDataAttributesFor } from '@/shared/Filter/utils'
import { DataAttribute } from '@/routes/endpoints'
import { flattenObject } from '@/helpers'

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
      taxon_determinations: getTaxonDetermination(taxon_determinations),
      dwc_occurrence,
      identifiers,
      data_attributes: getDataAttributesFor(body, item.id)
    }
  })
}
