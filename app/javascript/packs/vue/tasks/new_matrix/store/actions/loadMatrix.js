import { MutationNames } from '../mutations/mutations'
import ActionNames from '../actions/actionNames'
import { GetMatrixObservation } from '../../request/resources'

export default function ({ commit, state, dispatch }, id) {
  return new Promise((resolve, reject) => {
    GetMatrixObservation(id).then(response => {
      commit(MutationNames.SetMatrix, response)
      dispatch(ActionNames.GetMatrixObservationRows, id)
      dispatch(ActionNames.GetMatrixObservationColumns, id)
      dispatch(ActionNames.GetMatrixObservationRowsDynamic, id)
      dispatch(ActionNames.GetMatrixObservationColumnsDynamic, id)
      return resolve(response)
    }, (response) => {
      return reject(response)
    })
  })
}