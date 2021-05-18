import { MutationNames } from '../mutations/mutations'

export default function ({ commit, state }, descriptorId) {
  return state.request.getDescriptorDepictions(descriptorId)
    .then(depictions => {
      commit(MutationNames.SetDescriptorDepictions, {
        descriptorId,
        depictions
      })
    })
};
