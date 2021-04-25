import { MutationNames } from '../mutations/mutations'
import { TaxonNames } from 'routes/endpoints/TaxonNames.js'

export default function ({ commit }) {
  return new Promise(function (resolve, reject) {
    TaxonNames.loadRanks().then(response => {
      commit(MutationNames.SetRankList, response.body)
      return resolve()
    })
  })
}
