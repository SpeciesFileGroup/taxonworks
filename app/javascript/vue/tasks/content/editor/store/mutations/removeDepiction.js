export default (state, depiction) => {
  const index = state.depictions.findIndex(item => depiction.id === item.id)

  if (index >= 0) {
    state.depictions.splice(index, 1)
  }
}
