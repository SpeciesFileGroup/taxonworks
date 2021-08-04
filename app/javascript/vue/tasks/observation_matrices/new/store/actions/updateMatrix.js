import { ObservationMatrix } from 'routes/endpoints'

export default ({ state }) =>
  new Promise((resolve, reject) => {
    const data = {
      id: state.matrix.id,
      name: state.matrix.name
    }

    ObservationMatrix.update(state.matrix.id, { observation_matrix: data }).then(response => {
      TW.workbench.alert.create('Matrix was successfully updated.', 'notice')
      return resolve(response.body)
    })
  })
