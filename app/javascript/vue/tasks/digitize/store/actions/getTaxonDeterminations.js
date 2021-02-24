import { GetTaxonDeterminationCO } from '../../request/resources'
import { MutationNames } from '../mutations/mutations'

export default function ({ commit, state }, id) {
  return new Promise((resolve, reject) => { 
    GetTaxonDeterminationCO(id).then(response => {
      commit(MutationNames.SetTaxonDeterminations, response.body)
      resolve(response.body)
    }, error => {
      reject(error)
    })
  })
}