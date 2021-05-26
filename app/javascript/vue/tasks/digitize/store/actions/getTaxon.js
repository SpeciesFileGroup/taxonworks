import { TaxonName } from 'routes/endpoints'
import { MutationNames } from '../mutations/mutations'

export default ({ commit }, id) =>
  new Promise((resolve, reject) => {
    commit(MutationNames.SetTypeMaterialProtonymId, id)
    TaxonName.find(id).then(response => {
      commit(MutationNames.SetTypeMaterialTaxon, response.body)
      resolve(response.body)
    }, error => {
      reject(error)
    })
  })
