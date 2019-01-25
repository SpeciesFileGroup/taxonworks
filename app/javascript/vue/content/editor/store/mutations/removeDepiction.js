export default function (state, depiction) {
  var position = state.depictions.findIndex(item => {
    if (depiction.id === item.id) {
      return true
    }
  })
  if (position >= 0) {
    state.depictions.splice(position, 1)
  }
}
