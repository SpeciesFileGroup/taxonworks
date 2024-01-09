import { makeInitialState } from '../store'

export default (state) => {
  console.log(Object.assign(state, makeInitialState()))
}
