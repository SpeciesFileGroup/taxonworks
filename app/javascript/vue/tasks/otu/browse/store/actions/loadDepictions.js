import { MutationNames } from '../mutations/mutations'
import { Otu } from 'routes/endpoints'

export default ({ commit, state }, id) => {
  Otu.depictions(id).then(response => {
    commit(MutationNames.SetDepictions, state.depictions.concat(response.body))
  })
}
