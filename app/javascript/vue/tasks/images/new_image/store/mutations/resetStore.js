import { makeInitialState } from '../store'

export default (state) => {
  const newState = makeInitialState()
  newState.settings = state.settings
  const locked = Object.keys(state.settings.lock).filter(key => state.settings.lock[key])
  locked.forEach(key => {
    newState[key] = state[key]
  })
  Object.assign(state, newState)
}
