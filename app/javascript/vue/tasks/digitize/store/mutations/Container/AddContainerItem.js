export default (state, value) => {
  const index = state.containerItems.findIndex((item) => item.id == value.id)

  if (index >= 0) {
    state.containerItems[index] = value
  }
  else {
    state.containerItems.push(value)
  }
}
