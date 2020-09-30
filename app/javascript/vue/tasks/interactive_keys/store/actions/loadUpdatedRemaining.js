import { GetInteractiveKey } from '../../request/resources'
import { MutationNames } from '../mutations/mutations'
import { GetterNames } from '../getters/getters'

export default ({ commit, getters, state }) => {
  const filters = { selected_descriptors: getters[GetterNames.GetFilter] }
  return new Promise((resolve, reject) => {
    state.settings.isLoading = true
    GetInteractiveKey(state.observationMatrix.observation_matrix_id, filters).then(response => {
      commit(MutationNames.SetObservationMatrix, Object.assign({}, state.observationMatrix, { remaining: response.body.remaining, eliminated: response.body.eliminated } ))
      state.settings.isLoading = false
      resolve(response)
    }, error => {
      reject(error)
    })
  })
}
