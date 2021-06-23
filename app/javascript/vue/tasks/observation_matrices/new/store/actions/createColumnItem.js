import { ObservationMatrixColumnItem } from 'routes/endpoints'
import ActionNames from '../actions/actionNames'

export default ({ state, dispatch }, data) =>
  new Promise((resolve, reject) => {
    ObservationMatrixColumnItem.create({ observation_matrix_column_item: data }).then(response => {
      dispatch(ActionNames.GetMatrixObservationColumns, state.matrix.id)
      dispatch(ActionNames.GetMatrixObservationColumnsDynamic, state.matrix.id)
      TW.workbench.alert.create('Column item was successfully created.', 'notice')
      return resolve(response)
    })
  })
