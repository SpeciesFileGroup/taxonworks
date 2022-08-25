import { Observation } from 'routes/endpoints'
import { MutationNames } from '../mutations/mutations'
import makeObservation from '../../helpers/makeObservation'

export default ({ commit }, payload) => {
  Observation.where(payload).then(({ body }) => {
    body.forEach(obs => commit(MutationNames.SetObservation, makeObservation(obs)))
  })
}
