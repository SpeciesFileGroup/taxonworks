import { makeInitialState } from '../store'

export default function(state) {
  Object.assign(state, makeInitialState())
}