import { TaxonName } from 'routes/endpoints'
import { MutationNames } from '../mutations/mutations'

export default ({ commit }, id) => {
  TaxonName.find(id, { extend: ['type_taxon_name_relationship' ]}).then(response => {
    commit(MutationNames.SetTaxonName, response.body)
  })
}
