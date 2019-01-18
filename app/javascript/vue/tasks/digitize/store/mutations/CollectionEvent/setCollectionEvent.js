export default function(state, value) {
  value.roles_attributes = (value.hasOwnProperty('roles') ? value.roles : [])
  state.collection_event = value
}