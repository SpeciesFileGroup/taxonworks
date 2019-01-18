export default function(state, value) {
  value.roles_attributes = (value.hasOwnProperty('roles') ? value.roles : [])
  state.taxon_determination = value
}