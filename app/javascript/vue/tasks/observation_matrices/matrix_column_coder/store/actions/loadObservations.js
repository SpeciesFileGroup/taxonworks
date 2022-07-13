import { Observation } from 'routes/endpoints'
import makeObservation from 'tasks/observation_matrices/matrix_row_coder/store/helpers/makeObservation'

export default ({ state }, descriptorId) => {
  Observation.where({ descriptor_id: descriptorId }).then(({ body }) => {
    state.observations = body.map(obs => makeObservation(obs))
  })
}
