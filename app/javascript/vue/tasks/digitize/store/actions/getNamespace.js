import { GetNamespace } from '../../request/resources'
import { MutationNames } from '../mutations/mutations'

export default function ({ commit }, id) {
  return new Promise((resolve, reject) => {
    GetNamespace(id).then(namespace => {
      commit(MutationNames.SetNamespaceSelected, namespace.name)
      return resolve(namespace)
    })
  })
}