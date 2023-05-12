export default (state, value) => {
  state.geographicArea = value

  if (!value) {
    state.collecting_event.meta_prioritize_geographic_area = null
  }
}
