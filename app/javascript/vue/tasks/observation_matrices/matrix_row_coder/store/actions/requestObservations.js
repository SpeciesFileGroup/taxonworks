import { MutationNames } from '../mutations/mutations'
import makeObservation from '../helpers/makeObservation'

export default function ({ commit, state }, { descriptorId, otuId }) {
  return state.request.getObservations(otuId, descriptorId)
    .then(observationData => observationData.map(makeObservation))
    .then(observations => observations.forEach(observation => commit(MutationNames.SetObservation, observation)))
}
