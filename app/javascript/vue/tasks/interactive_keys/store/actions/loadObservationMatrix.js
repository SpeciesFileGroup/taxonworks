import { GetObservationMatrix } from '../../request/resources'
import { MutationNames } from '../mutations/mutations'

export default ({ commit }, id) => {
  return new Promise((resolve, reject) => {
    GetObservationMatrix(id).then(response => {
      commit(MutationNames.SetObservationMatrix, response.body)
      resolve(response)
    }, error => {
      reject(error)
    })
  })
}
