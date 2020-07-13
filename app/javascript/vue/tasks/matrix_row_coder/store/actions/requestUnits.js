import { MutationNames } from '../mutations/mutations'

export default function ({ commit, state }) {
  return state.request.getUnits()
    .then(units => {
      commit(MutationNames.SetUnits, units)
    })
}
