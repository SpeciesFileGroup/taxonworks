import { makeInitialState } from '../store.js'

export default state => {
  const {
    preferences,
    project_preferences
  } = state

  history.replaceState(null, null, '/tasks/accessions/comprehensive')
  state = Object.assign(state, makeInitialState())
  state.preferences = preferences
  state.project_preferences = project_preferences
}
