export default (state, id) => {
  const index = state.containerItems.findIndex(item => item.id === id)

  if (index > -1) {
    state.containerItems.splice(index, 1)
  }
}
