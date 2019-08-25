export default function (state, status) {
  var position = state.taxonStatusList.findIndex(item => {
    if (item.type == status.type) {
      return true
    }
  })
  if (position >= 0) {
    state.taxonStatusList.splice(position, 1)
  }
}
