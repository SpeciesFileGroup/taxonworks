import { makeInitialState } from '../store'

export default (state) => {
  Object.assign(state, makeInitialState())
}
