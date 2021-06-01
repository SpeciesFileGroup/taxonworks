import Vue from 'vue'

export default (state, georeference) => {
  const index = state.georeferences.findIndex(item => item.id === georeference.id)
  if (index > -1) {
    Vue.set(state.georeferences, index, georeference)
  } else {
    state.georeferences.push(georeference)
  }
}
