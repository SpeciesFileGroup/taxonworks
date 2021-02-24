import { updateTaxonName } from '../../request/resources'
import { MutationNames } from '../mutations/mutations'

export default function ({ commit, state }, citationId) {
  const data = {
    id: state.taxon_name.id,
    origin_citation_attributes: {
      id: citationId,
      _destroy: true
    }
  }
  updateTaxonName(data).then(response => {
    commit(MutationNames.SetCitation, response.body)
  })
}
