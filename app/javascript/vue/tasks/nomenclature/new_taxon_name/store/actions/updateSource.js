import { updateTaxonName } from '../../request/resources'
import { MutationNames } from '../mutations/mutations'

export default function ({ commit, state, dispatch }, citation) {
  return new Promise(function (resolve, reject) {

    const taxonName = {
      id: state.taxon_name.id,
      origin_citation_attributes: {
        id: citation.id,
        source_id: citation.source_id,
        pages: citation.pages
      }
    }

    updateTaxonName(taxonName).then(response => {
      dispatch('loadSoftValidation', 'taxon_name')
      state.taxon_name.origin_citation = response.body.origin_citation
      commit(MutationNames.UpdateLastSave)
      return resolve(response)
    }, response => {
      return reject(response)
    })
  })
}