export default (state, content) => {
  const index = state.recent.contents.findIndex(item => content.id === item.id)

  if (index < 0) {
    state.recent.contents.unshift(content)
  } else {
    state.recent.contents.unshift(state.recent.contents.splice(index, 1)[0])
  }
}
