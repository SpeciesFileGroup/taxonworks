import Vue from 'vue'

export default function (state, status) {
  var position = state.taxonStatusList.findIndex(item => {
    if (item.id == status.id || item.type == status.type) {
      return true
    }
  })
  if (position < 0) {
    state.taxonStatusList.push(status)
  } else {
    Vue.set(state.taxonStatusList, position, status)
  }
}
