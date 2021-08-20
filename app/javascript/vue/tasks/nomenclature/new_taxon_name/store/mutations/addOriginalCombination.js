export default (state, record) => {
  state.original_combination[record.inverse_assignment_method] = record
}
