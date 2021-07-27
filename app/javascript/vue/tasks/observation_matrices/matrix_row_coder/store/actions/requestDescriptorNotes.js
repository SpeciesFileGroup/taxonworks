import { MutationNames } from '../mutations/mutations'

export default function ({ commit, state }, descriptorId) {
  return state.request.getDescriptorNotes(descriptorId)
    .then(descriptorNotes => {
      commit(MutationNames.SetDescriptorNotes, {
        descriptorId,
        notes: descriptorNotes
      })
    })
};
