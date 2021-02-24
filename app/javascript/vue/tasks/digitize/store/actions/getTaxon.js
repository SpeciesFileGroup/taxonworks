import { GetTaxon } from '../../request/resources'
import { MutationNames } from '../mutations/mutations'

export default function ({ commit }, id) {
  return new Promise((resolve, reject) => {
    commit(MutationNames.SetTypeMaterialProtonymId, id)
    GetTaxon(id).then(response => {
      commit(MutationNames.SetTypeMaterialTaxon, response.body)
      resolve(response.body)
    }, error => {
      reject(error)
    })
  })
}