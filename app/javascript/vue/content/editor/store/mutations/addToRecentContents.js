export default function (state, content) {
  var position = state.recent.contents.findIndex(item => {
    if (content.id === item.id) {
      return true
    }
  })
  if (position < 0) {
    state.recent.contents.unshift(content)
  } else {
    state.recent.contents.unshift(state.recent.contents.splice(position, 1)[0])
  }
}
