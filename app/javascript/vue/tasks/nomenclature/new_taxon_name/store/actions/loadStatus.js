import { loadStatus } from '../../request/resources'
import { MutationNames } from '../mutations/mutations'

export default function ({ commit }) {
  return new Promise(function (resolve, reject) {
    loadStatus().then(response => {
      commit(MutationNames.SetStatusList, response.body)
      return resolve()
    })
  })
}
