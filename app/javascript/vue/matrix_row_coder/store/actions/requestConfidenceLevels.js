import { MutationNames } from '../mutations/mutations'

export default function ({ commit, state }) {
  commit(MutationNames.SetConfidenceLevels, state.request.getConfidenceLevels())
};
