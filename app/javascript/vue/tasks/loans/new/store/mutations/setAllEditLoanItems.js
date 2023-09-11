export default (state) => {
  state.edit_loan_items = state.loan_items.map((item) => item.id)
}
