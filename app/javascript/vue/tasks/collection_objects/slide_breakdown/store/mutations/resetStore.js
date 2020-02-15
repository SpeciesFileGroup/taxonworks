import { makeInitialState }  from '../store.js'

export default function(state) {
  state = Object.assign(state, makeInitialState())
}