import { makeInitialState }  from '../store'

export default function(state) {
  let preferences = state.preferences
  state = Object.assign(state, makeInitialState())
  state.preferences = preferences
}