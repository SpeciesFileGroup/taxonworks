export default (state, id) => {
  const index = state.taxon_determinations.findIndex(item => item.id === id)

  state.taxon_determinations.splice(index, 1)
}
