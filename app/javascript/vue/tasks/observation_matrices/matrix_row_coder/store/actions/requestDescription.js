import { MutationNames } from '../mutations/mutations'

export default function ({ commit, state }, rowId) {
  return state.request.getDescription(rowId)
    .then(({ generated_description }) => {
      commit(MutationNames.SetDescription, generated_description)
    })
}
