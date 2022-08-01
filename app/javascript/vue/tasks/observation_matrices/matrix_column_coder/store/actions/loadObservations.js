import { Observation } from 'routes/endpoints'
import { MutationNames } from '../mutations/mutations'
import makeObservation from '../../helpers/makeObservation'

export default ({ commit }, { descriptorId, extend }) => {
  Observation.where({ descriptor_id: descriptorId, extend, per: 5000 }).then(({ body }) => {
    body.forEach(obs => commit(MutationNames.SetObservation, makeObservation(obs)))
  })
}
