export default function(state, value) {
  value.roles_attributes = (value.hasOwnProperty('collector_roles') ? value.collector_roles : [])
  state.collection_event = value
}