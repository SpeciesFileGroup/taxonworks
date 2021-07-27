import { MutationNames } from '../mutations/mutations'

export default function ({ commit, state }, rowId) {
  return state.request.getDescription(rowId)
    .then(description => {
      commit(MutationNames.SetDescription, description)
    })
}
