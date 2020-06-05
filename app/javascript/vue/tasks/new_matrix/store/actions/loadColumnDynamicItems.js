import { MutationNames } from '../mutations/mutations'
import { GetMatrixObservationColumnsDynamic } from '../../request/resources'

export default function ({ commit, state }, id) {
  return new Promise((resolve, reject) => {
    return GetMatrixObservationColumnsDynamic(id).then(response => {
      commit(MutationNames.SetMatrixColumnsDynamic, response.body)
      return resolve(response)
    }, (response) => {
      return reject(response)
    })
  })
}
