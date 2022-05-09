import { Citation, TaxonName } from "routes/endpoints"
import { chunkArray } from "helpers/arrays.js"
import { TAXON_NAME, TAXON_NAME_CLASSIFICATION } from "constants/index.js"
import extend from '../../const/extendRequest.js'

const MAX_PER_REQUEST = 25

export default ({ state }, payload) => {
  const {
    sourceId,
    type,
    page,
    per
  } = payload

  const requestCitations = Citation.where({
    citation_object_type: type,
    source_id: sourceId,
    extend,
    page,
    per,
  })
  
  requestCitations.then(async ({ body }) => {
    if (type === TAXON_NAME) {
      state.citations[type] = await loadTaxonNamesIntoList(body)
    } else {
      state.citations[type] = body
    }
  })

  return requestCitations
}

const loadTaxonNamesIntoList = list => 
  new Promise((resolve, reject) => {
    const arrIds = chunkArray(list.map(item => item.citation_object_id), MAX_PER_REQUEST)
    const requestTaxons = arrIds.map(ids => TaxonName.where({ taxon_name_id: ids }))

    Promise.all(requestTaxons).then(responses => {
      const taxonList = [].concat(...responses.map(r => r.body))

      resolve(list.map(item => ({
        ...item,
        citation_object: taxonList.find(taxon => taxon.id === item.citation_object_id) || citation_object
      })))
    })
  })
