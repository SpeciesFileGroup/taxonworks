import { GetTaxonName } from '../../request/resources'
import { MutationNames } from '../mutations/mutations'

export default ({ commit }, id) => {
  GetTaxonName(id).then(response => {
    commit(MutationNames.SetTaxonName, response.body)
  })
}
