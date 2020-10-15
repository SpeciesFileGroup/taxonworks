import { makeInitialState } from '../store.js'

export default (state) => {
  Object.assign(state, makeInitialState())
}
