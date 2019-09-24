export default function (state, id) {
  var position = state.loan_items.findIndex(item => {
    if (item.id == id) {
      return true
    }
  })
  if (position >= 0) {
    state.loan_items.splice(position, 1)
  }
};
