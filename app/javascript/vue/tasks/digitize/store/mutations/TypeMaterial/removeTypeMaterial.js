export default (state, id) => {
  const index = state.typeSpecimens.findIndex(item => item.id === id || item.internalId === id)

  state.typeSpecimens.splice(index, 1)
}
