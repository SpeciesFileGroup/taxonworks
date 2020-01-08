export default function(state, value) {
  let index = state.tags.findIndex(item => {
    return item.id == value.id
  })
  if(index > -1) {
    state.tags[index] = value
  }
  else {
    state.tags.push(value)
  }
}