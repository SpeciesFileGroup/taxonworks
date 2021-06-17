export default (state, loan_item) => {
  const position = state.loan_items.findIndex(item => item.id === loan_item.id)

  if (position < 0) {
    state.loan_items.push(loan_item)
  } else {
    state.loan_items[position] = loan_item
  }
}
