import { MutationNames } from '../mutations/mutations'
import { GetDepictions } from '../../request/resources'

export default ({ commit, state }, id) => {
  GetDepictions('otus', id).then(response => {
    commit(MutationNames.SetDepictions, state.depictions.concat(response.body))
  })
}
