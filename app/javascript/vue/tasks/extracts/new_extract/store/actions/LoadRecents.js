import { MutationNames } from '../mutations/mutations'
import { GetExtracts } from '../../request/resources'

export default ({ commit }) => {
  GetExtracts({ recent: true, per: 12 }).then(({ body }) => {
    commit(MutationNames.SetRecents, body)
  })
}