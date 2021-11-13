export default (state, value) => {
  const index = state.biocurations.findIndex(item => item.id === value)

  if (index > -1) {
    state.biocurations.splice(index, 1)
  }
}