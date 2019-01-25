import Vue from 'vue'

export default function (state, record) {
  Vue.set(state.original_combination, record.inverse_assignment_method, record)
}
