export default (state, newContent) => {
  state.selected.content = newContent
  state.selected.otu = newContent.otu
  state.selected.topic = newContent.topic
}
