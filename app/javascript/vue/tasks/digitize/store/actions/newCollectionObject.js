import { MutationNames } from '../mutations/mutations'

export default function ({ commit, state }) {
  commit(MutationNames.NewCollectionObject)
  commit(MutationNames.NewTypeMaterial)
}