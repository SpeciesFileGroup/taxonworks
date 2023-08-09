import { Citation, TaxonName } from '@/routes/endpoints'
import { TAXON_NAME } from '@/constants/index.js'
import extend from '../../const/extendRequest.js'

export default async ({ state }, payload) => {
  const { sourceId, type, page, per } = payload

  const citationResponse = await Citation.where({
    citation_object_type: type,
    source_id: sourceId,
    extend,
    page,
    per
  })

  if (type === TAXON_NAME) {
    state.citations[type] = await loadTaxonNamesIntoList(citationResponse.body)
  } else {
    state.citations[type] = citationResponse.body
  }

  return citationResponse
}

async function loadTaxonNamesIntoList(list) {
  const taxonIds = list.map((item) => item.citation_object_id)
  const { body } = await TaxonName.all({
    taxon_name_id: taxonIds
  })

  return list.map((item) => ({
    ...item,
    citation_object:
      body.find((taxon) => taxon.id === item.citation_object_id) ||
      item.citation_object
  }))
}
