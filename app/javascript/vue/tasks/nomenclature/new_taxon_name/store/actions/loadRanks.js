import { loadRanks } from '../../request/resources'
import { MutationNames } from '../mutations/mutations'

export default function ({ commit, state }) {
  return new Promise(function (resolve, reject) {
    loadRanks().then(response => {
      commit(MutationNames.SetRankList, response)
      return resolve()
    })
  })
}
