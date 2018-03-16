import { MutationNames } from '../mutations/mutations'
import { GetMatrixObservation } from '../../request/resources'

export default function ({ commit, state }, id) {
  return new Promise((resolve, rejected) => {
    GetMatrixObservation(id).then(response => {
      commit(MutationNames.SetMatrix, response)
      return resolve(response)
    }, (response) => {
      return rejected(response)
    })
  })
};