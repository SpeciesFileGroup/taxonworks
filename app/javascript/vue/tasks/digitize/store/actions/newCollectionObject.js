import { MutationNames } from '../mutations/mutations'

export default function ({ commit, state }) {
  console.log("asdfasdf")
  commit(MutationNames.NewCollectionObject)
  commit(MutationNames.NewTypeMaterial)
}