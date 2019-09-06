import { MutationNames } from '../mutations/mutations'

export default function ({ commit, state }, material) {
  commit(MutationNames.SetTypeMaterial, material)
};
