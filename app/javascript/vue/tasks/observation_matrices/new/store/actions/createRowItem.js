import { ObservationMatrixRowItem } from 'routes/endpoints'
import ActionNames from '../actions/actionNames'

export default ({ state, dispatch }, data) =>
  new Promise((resolve, reject) => {
    ObservationMatrixRowItem.create({ observation_matrix_row_item: data }).then(response => {
      dispatch(ActionNames.GetMatrixObservationRows, { per: 500 })
      dispatch(ActionNames.GetMatrixObservationRowsDynamic, state.matrix.id)
      TW.workbench.alert.create('Row item was successfully created.', 'notice')
      return resolve(response)
    })
  })
