import Vue from 'vue'

module.exports = function (state, status) {
  var position = state.taxonStatusList.findIndex(item => {
    if (item.type == status.type) {
      return true
    }
  })
  if (position < 0) {
    state.taxonStatusList.push(status)
  } else {
    Vue.set(state.taxonStatusList, position, status)
  }
}
