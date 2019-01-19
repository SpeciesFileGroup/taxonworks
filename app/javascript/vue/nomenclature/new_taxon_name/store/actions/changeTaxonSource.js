import { changeTaxonSource } from '../../request/resources'
import { MutationNames } from '../mutations/mutations'

export default function ({ commit, state }, source) {
  changeTaxonSource(state.taxon_name.id, source, state.taxon_name.origin_citation).then(response => {
    commit(MutationNames.SetCitation, response)
  })
}
