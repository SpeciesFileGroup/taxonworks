import { TaxonName } from 'routes/endpoints'
import { MutationNames } from '../mutations/mutations'

export default ({ commit }, id) => {
  TaxonName.find(id).then(response => {
    commit(MutationNames.SetTaxonName, response.body)
  })
}
