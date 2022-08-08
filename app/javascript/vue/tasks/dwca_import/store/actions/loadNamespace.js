import { Namespace } from 'routes/endpoints'
import { MutationNames } from '../mutations/mutations'

export default async ({ state, commit }, namespaceId) => {
  if (state.namespaces[namespaceId]) return

  state.namespaces[namespaceId] = {}
  const namespace = (await Namespace.find(namespaceId)).body

  commit(MutationNames.SetNamespace, namespace)
}
