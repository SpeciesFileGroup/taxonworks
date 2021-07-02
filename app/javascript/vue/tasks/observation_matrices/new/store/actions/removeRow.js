import { ObservationMatrixRowItem } from 'routes/endpoints'
import ActionNames from '../actions/actionNames'

export default ({ state, dispatch }, id) =>
  new Promise((resolve, reject) => {
    return ObservationMatrixRowItem.destroy(id).then(response => {
      dispatch(ActionNames.GetMatrixObservationRows, { per: 500 })
      dispatch(ActionNames.GetMatrixObservationRowsDynamic, state.matrix.id)
      return resolve(response)
    }, (response) => {
      return reject(response)
    })
  })
