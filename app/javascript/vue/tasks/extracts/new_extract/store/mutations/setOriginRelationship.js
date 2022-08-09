export default (state, value) => {
  state.originRelationship = value
  state.lastChange = Date.now()
}
