import { MutationNames } from '../mutations/mutations'
import { TaxonName } from 'routes/endpoints'

export default function ({ commit }) {
  return new Promise(function (resolve, reject) {
    TaxonName.loadRanks().then(response => {
      commit(MutationNames.SetRankList, response.body)
      return resolve()
    })
  })
}
