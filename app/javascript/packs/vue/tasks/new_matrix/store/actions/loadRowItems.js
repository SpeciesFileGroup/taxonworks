import { MutationNames } from '../mutations/mutations'
import { GetMatrixObservationRows } from '../../request/resources'

export default function ({ commit, state }, id) {
  return new Promise((resolve, reject) => {
      return GetMatrixObservationRows(id).then(rows => {
        commit(MutationNames.SetMatrixRows, rows)
        return resolve(rows)
      }, (response) => {
        return reject(response)
      })
  })
}