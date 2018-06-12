export default function (state, loan_item_id) {
  var position = state.edit_loan_items.findIndex(id => {
    if (id == loan_item_id) {
      return true
    }
  })
  if (position < 0) {
    state.edit_loan_items.push(loan_item_id)
  }
};
