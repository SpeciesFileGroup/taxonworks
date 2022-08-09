import { removeFromArray } from 'helpers/arrays.js'

export default (state, protocol) => {
  removeFromArray(state.protocols, protocol)
  state.lastChange = Date.now()
}
