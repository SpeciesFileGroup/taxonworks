import { Namespace } from 'routes/endpoints'
import { MutationNames } from '../mutations/mutations'

export default ({ commit }, namespaceIds) => {
  const ids = [...new Set(namespaceIds)]
  const requests = ids.map(id => Namespace.find(id))

  Promise.all(requests).then(responses => {
    responses.forEach(({ body }) => {
      commit(MutationNames.SetNamespace, body)
    })
  })
}
