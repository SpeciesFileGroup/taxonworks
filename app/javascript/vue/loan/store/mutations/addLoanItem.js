import Vue from 'vue'

export default function (state, loan_item) {
  var position = state.loan_items.findIndex(item => {
    if (item.id == loan_item.id) {
      return true
    }
  })
  if (position < 0) {
    state.loan_items.push(loan_item)
  } else {
    Vue.set(state.loan_items, position, loan_item)
  }
};
