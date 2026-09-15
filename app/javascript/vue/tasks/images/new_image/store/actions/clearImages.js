import { MutationNames } from '../mutations/mutations'

export default ({ commit }) => {
  commit(MutationNames.SetImagesCreated, [])
  commit(MutationNames.SetDepictions, [])
  commit(MutationNames.SetAttributionsCreated, [])
  commit(MutationNames.ClearAppliedByImage)
}
