import { MutationNames } from '../mutations/mutations'
import { Conveyance, Sound } from '@/routes/endpoints'

export default ({ commit, state }, id) => {
  state.loadState.conveyances = true
  Conveyance.where({
    otu_id: [id],
    otu_scope: ['all'],
    per: 500
  })
    .then(({ body }) => {
      commit(MutationNames.SetConveyances, state.conveyances.concat(body))
    })
    .catch(() => {})
    .finally(() => {
      state.loadState.conveyances = false
    })
}
