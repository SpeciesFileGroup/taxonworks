import Vue from 'vue'
export default function (state, relationship) {
  for (var key in state.original_combination) {
    if (state.original_combination[key].type == relationship.type) {
      Vue.delete(state.original_combination, key)
      return true
    }
  }
}
