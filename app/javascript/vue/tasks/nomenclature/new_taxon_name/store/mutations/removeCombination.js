export default (state, id) => {
  const index = state.combinations.findIndex(combination => combination.id === id)

  if (index > -1) {
    state.combinations.splice(index, 1)
  }
}