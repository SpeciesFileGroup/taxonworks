export default (state, relationship) => {
  for (const key in state.original_combination) {
    if (state.original_combination[key].type === relationship.type) {
      delete state.original_combination[key]
      return true
    }
  }
}
