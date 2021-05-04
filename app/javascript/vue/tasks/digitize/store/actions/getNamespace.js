import { Namespace } from 'routes/endpoints'
import { MutationNames } from '../mutations/mutations'

export default ({ commit }, id) =>
  Namespace.find(id).then(response => {
    commit(MutationNames.SetNamespaceSelected, response.body.name)
  })
