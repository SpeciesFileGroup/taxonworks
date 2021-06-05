import { TaxonName } from 'routes/endpoints'
import { MutationNames } from '../mutations/mutations'

export default ({ commit }, id) => {
  commit(MutationNames.SetTypeMaterialProtonymId, id)
  TaxonName.find(id).then(response => {
    commit(MutationNames.SetTypeMaterialTaxon, response.body)
  })
}
