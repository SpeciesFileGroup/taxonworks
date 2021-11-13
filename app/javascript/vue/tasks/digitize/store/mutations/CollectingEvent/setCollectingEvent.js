export default (state, ce) => {
  state.collecting_event = {
    ...ce,
    roles_attributes: ce?.collector_roles || []
  }
}
