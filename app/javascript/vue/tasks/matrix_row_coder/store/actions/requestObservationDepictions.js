import { MutationNames } from '../mutations/mutations'

export default function ({ commit, state }, observationId) {
  return state.request.getObservationDepictions(observationId)
    .then(depictions => {
      commit(MutationNames.SetObservationDepictions, {
        observationId,
        depictions
      })
    })
};
