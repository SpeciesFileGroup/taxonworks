export default ({ state }, value) => {
  for (const key in state.settings.applied) {
    state.settings.applied[key] = value
  }
}
