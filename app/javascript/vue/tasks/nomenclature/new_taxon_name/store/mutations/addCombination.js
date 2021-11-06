export default (state, combination) => {
  const index = state.combinations.findIndex(item => item.id === combination.id)

  if (index < 0) {
    state.combinations.push(combination)
  } else {
    state.combinations[index] = combination
  }
}
