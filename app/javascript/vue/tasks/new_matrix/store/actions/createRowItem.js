import { CreateRowItem } from '../../request/resources'
import ActionNames from '../actions/actionNames'

export default function ({ commit, state, dispatch }, data) {
  return new Promise((resolve, reject) => {
    CreateRowItem({ observation_matrix_row_item: data }).then(response => {
      dispatch(ActionNames.GetMatrixObservationRows, { per: 500 })
      dispatch(ActionNames.GetMatrixObservationRowsDynamic, state.matrix.id)
      TW.workbench.alert.create('Row item was successfully created.', 'notice')
      return resolve(response)
    })
  })
}
