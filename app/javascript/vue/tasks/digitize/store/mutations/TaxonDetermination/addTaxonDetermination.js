export default (state, value) => {
  if (value.id) {
    const index = state.taxon_determinations.findIndex(item => item.id === value.id)
    if (index > -1) {
      state.taxon_determinations[index] = value
    } else {
      state.taxon_determinations.push(value)
    }
  } else {
    state.taxon_determinations.push(value)
  }
}
