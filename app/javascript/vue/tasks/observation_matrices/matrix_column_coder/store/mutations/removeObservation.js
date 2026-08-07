export default (state, observationId) => {
  const index = state.observations.findIndex(o => o.id === observationId)

  state.observations.splice(index, 1)
}
