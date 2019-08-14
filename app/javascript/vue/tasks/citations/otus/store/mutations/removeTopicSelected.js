export default function (state, id) {
  var position = state.selected.topics.findIndex(item => {
    if (id === item.id) {
      return true
    }
  })
  if (position >= 0) {
    state.selected.topics.splice(position, 1)
  }
}
