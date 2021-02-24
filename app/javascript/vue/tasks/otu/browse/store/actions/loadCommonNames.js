import { MutationNames } from '../mutations/mutations'
import { GetCommonNames } from '../../request/resources'

export default ({ commit, state }, id) => {
  GetCommonNames(id).then(response => {
    commit(MutationNames.SetCommonNames, state.commonNames.concat(response.body))
  })
}
