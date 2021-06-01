import { GetInteractiveKey } from '../../request/resources'
import { MutationNames } from '../mutations/mutations'
import { GetterNames } from '../getters/getters'

export default ({ commit, getters, state }) => {
  const filters = getters[GetterNames.GetFilter]
  return new Promise((resolve, reject) => {
    state.settings.isRefreshing = true
    GetInteractiveKey(state.observationMatrix.observation_matrix_id, filters).then(response => {
      commit(MutationNames.SetObservationMatrix, Object.assign({}, state.observationMatrix, { remaining: response.body.remaining, eliminated: response.body.eliminated } ))
      state.settings.isRefreshing = false
      resolve(response)
    }, error => {
      reject(error)
    })
  })
}
