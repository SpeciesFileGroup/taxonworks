import { MutationNames } from '../mutations/mutations'
import { Extract } from 'routes/endpoints'

export default ({ commit }, extract) => {
  return Extract.protocolRelationships(extract.id).then(({ body }) => {
    commit(MutationNames.SetProtocols, body)
  })
}
