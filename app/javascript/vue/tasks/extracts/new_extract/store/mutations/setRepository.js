export default (state, value) => {
  state.repository = value
  state.lastChange = Date.now()
}
