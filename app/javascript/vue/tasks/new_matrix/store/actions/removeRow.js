import { RemoveRow } from '../../request/resources'
import ActionNames from '../actions/actionNames'

export default function ({ commit, state, dispatch }, id) {
  return new Promise((resolve, reject) => {
    return RemoveRow(id).then(response => {
      dispatch(ActionNames.GetMatrixObservationRows, { per: 500 })
      dispatch(ActionNames.GetMatrixObservationRowsDynamic, state.matrix.id)
      return resolve(response)
    }, (response) => {
      return reject(response)
    })
  })
}
