import Vue from 'vue'

module.exports = function (state, record) {
  Vue.set(state.original_combination, record.inverse_assignment_method, record)
}
