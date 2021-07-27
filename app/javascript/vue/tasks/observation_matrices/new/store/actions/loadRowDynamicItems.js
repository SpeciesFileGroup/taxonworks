import { MutationNames } from '../mutations/mutations'
import { GetMatrixObservationRowsDynamic } from '../../request/resources'

export default function ({ commit, state }, id) {
  return new Promise((resolve, reject) => {
    return GetMatrixObservationRowsDynamic(id).then(response => {
      commit(MutationNames.SetMatrixRowsDynamic, response)
      return resolve(response)
    }, (response) => {
      return reject(response)
    })
  })
}
