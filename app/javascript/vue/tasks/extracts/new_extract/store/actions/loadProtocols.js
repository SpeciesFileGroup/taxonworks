import { MutationNames } from '../mutations/mutations'
import { GetProtocols } from '../../request/resources'

export default ({ commit }, extract) => {
  GetProtocols(extract.id).then(({ body }) => {
    commit(MutationNames.SetProtocols, body)
  })
}
