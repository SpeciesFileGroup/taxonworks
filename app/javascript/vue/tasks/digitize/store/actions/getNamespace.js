import { GetNamespace } from '../../request/resources'
import { MutationNames } from '../mutations/mutations'

export default function ({ commit }, id) {
  return new Promise((resolve, reject) => {
    GetNamespace(id).then(response => {
      commit(MutationNames.SetNamespaceSelected, response.body.name)
      return resolve(response.body)
    }, error => {
      reject(error)
    })
  })
}