import Vue from 'vue'
export default function(state, value) {
  let index = state.collection_objects.findIndex((item) => {
    return item.id == value.id
  })
  if(index >= 0) {
    Vue.set(state.collection_objects, index, value)
  }
  else {
    state.collection_objects.push(value)
  }
}