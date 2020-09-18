import { makeInitialState } from '../store.js'
import { MutationNames } from '../mutations/mutations'

export default ({ commit }) => {
  const store = makeInitialState()
  delete store.preferences
  commit(MutationNames.SetStore, makeInitialState())
}
