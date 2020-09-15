import { GetMatrixObservationColumns } from '../../request/resources'
import { MutationNames } from '../mutations/mutations'

export default ({ commit }, matrixId) => {
  return new Promise((resolve, reject) => {
    GetMatrixObservationColumns(matrixId).then(response => {
      commit(MutationNames.SetObservationMatrixDescriptors, response.body)
      resolve(response)
    }, error => {
      reject(error)
    })
  })
}
