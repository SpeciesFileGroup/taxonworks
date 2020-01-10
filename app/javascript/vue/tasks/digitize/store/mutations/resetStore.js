import { makeInitialState }  from '../store.js'

export default function(state) {
  let preferences = state.preferences
  let COTypes = state.COTypes

  history.pushState(null, null, `/tasks/accessions/comprehensive`)
  state = Object.assign(state, makeInitialState())
  state.preferences = preferences
  state.COTypes = COTypes
}