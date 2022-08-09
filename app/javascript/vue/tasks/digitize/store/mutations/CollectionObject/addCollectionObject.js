export default (state, value) => {
  const index = state.collection_objects.findIndex((item) => item.id === value.id)

  if (index >= 0) {
    state.collection_objects[index] = value
  }
  else {
    state.collection_objects.push(value)
  }
}
