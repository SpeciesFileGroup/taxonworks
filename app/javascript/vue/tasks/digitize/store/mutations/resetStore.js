import { makeInitialState } from '../store.js'

export default state => {
  const preferences = state.preferences
  const COTypes = state.COTypes

  history.pushState(null, null, '/tasks/accessions/comprehensive')
  state = Object.assign(state, makeInitialState())
  state.preferences = preferences
  state.COTypes = COTypes
}
