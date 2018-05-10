import { MutationNames } from '../mutations/mutations'
import { GetMatrixObservationColumns } from '../../request/resources'

export default function ({ commit, state }, id) {
  return new Promise((resolve, reject) => {
      return GetMatrixObservationColumns(id).then(columns => {
        commit(MutationNames.SetMatrixColumns, columns)
        return resolve(columns)
      }, (response) => {
        return reject(response)
      })
  })
}