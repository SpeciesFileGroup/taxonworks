import { MutationNames } from '../mutations/mutations'
import { TaxonName } from 'routes/endpoints'

export default function ({ commit, state }, citationId) {
  const taxon_name = {
    id: state.taxon_name.id,
    origin_citation_attributes: {
      id: citationId,
      _destroy: true
    }
  }
  TaxonName.update(taxon_name.id, { taxon_name }).then(response => {
    commit(MutationNames.SetCitation, response.body)
  })
}
