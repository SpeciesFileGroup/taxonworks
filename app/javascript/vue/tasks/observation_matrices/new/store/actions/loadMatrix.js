import { MutationNames } from '../mutations/mutations'
import { ObservationMatrix } from 'routes/endpoints'
import ActionNames from '../actions/actionNames'

export default ({ commit, dispatch }, id) =>
  new Promise((resolve, reject) => {
    ObservationMatrix.find(id).then(response => {
      commit(MutationNames.SetMatrix, response.body)
      dispatch(ActionNames.GetMatrixObservationRows, { per: 500 })
      dispatch(ActionNames.GetMatrixObservationColumns, id)
      dispatch(ActionNames.GetMatrixObservationRowsDynamic, id)
      dispatch(ActionNames.GetMatrixObservationColumnsDynamic, id)
      return resolve(response)
    }, (response) => {
      return reject(response)
    })
  })
