import { MutationNames } from '../mutations/mutations'
import { GetMatrixObservationRowsDynamic } from '../../request/resources'

export default function ({ commit, state }, id) {
  return new Promise((resolve, reject) => {
      return GetMatrixObservationRowsDynamic(id).then(rows => {
        commit(MutationNames.SetMatrixRowsDynamic, rows)
        return resolve(rows)
      }, (response) => {
        return reject(response)
      })
  })
}