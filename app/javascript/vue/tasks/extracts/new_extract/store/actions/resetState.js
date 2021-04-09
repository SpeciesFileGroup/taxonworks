import { makeInitialState } from '../store'
import { MutationNames } from '../mutations/mutations'

export default ({ state, commit }) => {
  const initState = makeInitialState()
  const { settings: { lock } } = state

  Object.entries(lock).forEach(([key, isLocked]) => {
    if (isLocked) {
      initState[key] = state[key]
    }
  })

  commit(MutationNames.SetState, initState)
}
