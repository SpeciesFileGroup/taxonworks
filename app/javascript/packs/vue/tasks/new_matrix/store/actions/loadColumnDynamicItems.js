import { MutationNames } from '../mutations/mutations'
import { GetMatrixObservationColumnsDynamic } from '../../request/resources'

export default function ({ commit, state }, id) {
  return new Promise((resolve, reject) => {
      return GetMatrixObservationColumnsDynamic(id).then(columns => {
        commit(MutationNames.SetMatrixColumnsDynamic, columns)
        return resolve(columns)
      }, (response) => {
        return reject(response)
      })
  })
}