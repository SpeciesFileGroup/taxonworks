export default (state, value) => {
  const index = state.collection_objects.findIndex((item) => item.id == value)

  if (index >= 0) {
    state.collection_objects.splice(index, 1)
  }
}
