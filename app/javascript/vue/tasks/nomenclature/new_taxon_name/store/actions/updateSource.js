import { TaxonName } from 'routes/endpoints'
import { MutationNames } from '../mutations/mutations'

export default function ({ commit, state, dispatch }, citation) {
  return new Promise(function (resolve, reject) {
    const taxon_name = {
      id: state.taxon_name.id,
      origin_citation_attributes: {
        id: citation.id,
        source_id: citation.source_id,
        pages: citation.pages
      }
    }

    TaxonName.update(taxon_name.id, { taxon_name, extend: ['origin_citation', 'roles'] }).then(response => {
      dispatch('loadSoftValidation', 'taxon_name')
      state.taxon_name.origin_citation = response.body.origin_citation
      commit(MutationNames.UpdateLastSave)
      return resolve(response)
    }, response => {
      return reject(response)
    })
  })
}