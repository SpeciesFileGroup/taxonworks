import Vue from 'vue'
export default function(state, value) {
  let index = state.containerItems.findIndex((item) => {
    return item.id == value.id
  })
  if(index >= 0) {
    Vue.set(state.containerItems, index, value)
  }
  else {
    state.containerItems.push(value)
  }
}