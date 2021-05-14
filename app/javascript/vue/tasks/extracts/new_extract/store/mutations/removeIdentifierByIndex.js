export default (state, index) => {
  state.identifiers.splice(index, 1)
  state.lastChange = Date.now()
}
