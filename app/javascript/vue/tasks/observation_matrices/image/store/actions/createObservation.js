import ActionNames from './actionNames'

export default function ({ commit, state, dispatch }, data) {
  return new Promise((resolve, reject) => {
    CreateColumnItem({ observation_matrix_column_item: data }).then(response => {
      dispatch(ActionNames.GetMatrixObservationColumns, state.matrix.id)
      dispatch(ActionNames.GetMatrixObservationColumnsDynamic, state.matrix.id)
      TW.workbench.alert.create('Column item was successfully created.', 'notice')
      return resolve(response)
    })
  })
}
