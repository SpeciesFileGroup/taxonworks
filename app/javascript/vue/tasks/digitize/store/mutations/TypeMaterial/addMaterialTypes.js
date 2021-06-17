export default (state, value) => {
  const index = state.materialTypes.findIndex(item => item.id === value.id)

  if (index > -1) {
    state.materialTypes[index] = value
  } else {
    state.materialTypes.push(value)
  }
}
