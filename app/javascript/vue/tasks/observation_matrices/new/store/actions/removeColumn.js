import { ObservationMatrixColumnItem } from 'routes/endpoints'
import ActionNames from '../actions/actionNames'

export default ({ state, dispatch }, id) =>
  new Promise((resolve, reject) => {
    return ObservationMatrixColumnItem.destroy(id).then(response => {
      dispatch(ActionNames.GetMatrixObservationColumns, state.matrix.id)
      dispatch(ActionNames.GetMatrixObservationColumnsDynamic, state.matrix.id)
      return resolve(response)
    }, (response) => {
      return reject(response)
    })
  })
