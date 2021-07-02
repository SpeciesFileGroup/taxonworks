import { TaxonName } from 'routes/endpoints'
import { MutationNames } from '../mutations/mutations'

export default ({ commit }, id) => {
  TaxonName.originalCombination(id).then(response => {
    commit(MutationNames.SetOriginalCombination, response.body)
  })
}
