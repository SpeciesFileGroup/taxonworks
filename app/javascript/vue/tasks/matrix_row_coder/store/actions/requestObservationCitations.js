import { MutationNames } from '../mutations/mutations'

export default function ({ commit, state }, observationId) {
  return state.request.getObservationCitations(observationId)
    .then(citations => {
      commit(MutationNames.SetObservationCitations, {
        observationId,
        citations
      })
    })
};
