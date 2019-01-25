import { removeTaxonSource } from '../../request/resources'
import { MutationNames } from '../mutations/mutations'

export default function ({ commit, state }, citationId) {
  removeTaxonSource(state.taxon_name.id, citationId).then(response => {
    commit(MutationNames.SetCitation, response)
  })
}
