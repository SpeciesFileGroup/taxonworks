import { loadRelationships } from '../../request/resources'
import { MutationNames } from '../mutations/mutations'

export default function ({ commit, state }) {
  return new Promise(function (resolve, reject) {
    loadRelationships().then(response => {
      commit(MutationNames.SetRelationshipList, response.body)
      return resolve()
    })
  })
}
