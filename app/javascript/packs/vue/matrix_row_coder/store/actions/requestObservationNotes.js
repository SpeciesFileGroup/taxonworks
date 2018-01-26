import { MutationNames } from '../mutations/mutations'

export default function ({ commit, state }, observationId) {
  return state.request.getObservationNotes(observationId)
    .then(notes => {
      commit(MutationNames.SetObservationNotes, {
        observationId,
        notes
      })
    })
};
