import { RemoveColumn } from '../../request/resources'
import ActionNames from '../actions/actionNames'

export default function ({ commit, state, dispatch }, id) {
  return new Promise((resolve, reject) => {
    return RemoveColumn(id).then(response => {
      dispatch(ActionNames.GetMatrixObservationColumns, state.matrix.id)
      dispatch(ActionNames.GetMatrixObservationColumnsDynamic, state.matrix.id)
      return resolve(response)
    }, (response) => {
      return reject(response)
    })
  })
}
