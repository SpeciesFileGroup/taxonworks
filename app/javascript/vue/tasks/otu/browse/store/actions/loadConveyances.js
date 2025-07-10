import { OTU } from '@/constants'
import { MutationNames } from '../mutations/mutations'
import { Conveyance } from '@/routes/endpoints'

export default ({ commit, state }, id) => {
  state.loadState.conveyances = true
  Conveyance.where({
    conveyance_object_id: id,
    conveyance_object_type: OTU,
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
