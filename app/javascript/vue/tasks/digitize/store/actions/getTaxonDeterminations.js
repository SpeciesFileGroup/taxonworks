import { GetTaxonDeterminationCO } from '../../request/resources'
import { MutationNames } from '../mutations/mutations'

export default function ({ commit, state }, id) {
  GetTaxonDeterminationCO(id).then(response => {
    commit(MutationNames.SetTaxonDeterminations, response)
  })
}