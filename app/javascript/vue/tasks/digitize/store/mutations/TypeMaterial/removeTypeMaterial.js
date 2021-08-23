export default (state, id) => {
  const index = state.materialTypes.findIndex((item) => item.id === id)

  state.materialTypes.splice(index, 1)
}
