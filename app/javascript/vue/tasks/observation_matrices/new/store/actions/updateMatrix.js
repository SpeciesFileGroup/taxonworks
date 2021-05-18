import { UpdateMatrix } from '../../request/resources'

export default function ({ commit, state, dispatch }) {
  return new Promise((resolve, reject) => {
    let data = {
      id: state.matrix.id,
      name: state.matrix.name,
    }
    UpdateMatrix(state.matrix.id, data).then(response => {
      TW.workbench.alert.create('Matrix was successfully updated.', 'notice')
      return resolve(response.body)
    })
  })
}