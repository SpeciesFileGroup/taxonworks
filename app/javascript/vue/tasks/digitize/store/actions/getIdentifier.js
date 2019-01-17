import { GetIdentifier, GetNamespace } from '../../request/resources'
import { MutationNames } from '../mutations/mutations'

export default function ({ commit }, id) {
  return new Promise((resolve, reject) => {
    GetIdentifier(id).then(response => {
      commit(MutationNames.SetIdentifier, response)
      GetNamespace(response.namespace_id).then(namespace => {
        commit(MutationNames.SetNamespaceSelected, namespace.name)
        return resolve(response)
      })
    })
  })
}