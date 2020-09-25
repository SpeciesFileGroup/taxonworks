import { GetInteractiveKey } from '../../request/resources'
import { MutationNames } from '../mutations/mutations'
import { GetterNames } from '../getters/getters'

export default ({ commit, getters }, id) => {
  const filters = { selected_descriptors: getters[GetterNames.GetFilter] }
  return new Promise((resolve, reject) => {
    GetInteractiveKey(id, filters).then(response => {
      commit(MutationNames.SetObservationMatrix, response.body)
      resolve(response)
    }, error => {
      reject(error)
    })
  })
}
