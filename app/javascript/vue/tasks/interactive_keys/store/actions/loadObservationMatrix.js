import { GetInteractiveKey } from '../../request/resources'
import { MutationNames } from '../mutations/mutations'
import { GetterNames } from '../getters/getters'

export default ({ commit, getters, state }, id) => {
  const filters = getters[GetterNames.GetFilter]
  return new Promise((resolve, reject) => {
    state.settings.isLoading = true
    GetInteractiveKey(id, filters).then(response => {
      commit(MutationNames.SetObservationMatrix, response.body)
      state.settings.isLoading = false
      resolve(response)
    }, error => {
      reject(error)
    })
  })
}
