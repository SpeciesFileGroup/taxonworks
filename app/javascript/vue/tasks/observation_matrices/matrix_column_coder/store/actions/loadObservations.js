import { Observation } from 'routes/endpoints'
import { MutationNames } from '../mutations/mutations'
import makeObservation from '../../helpers/makeObservation'

export default ({ commit }, descriptorId) => {
  Observation.where({ descriptor_id: descriptorId }).then(({ body }) => {
    body.forEach(obs => commit(MutationNames.SetObservation, makeObservation(obs)))
  })
}
