export default function(state, value) {
  let index = state.citations.findIndex(item => {
    return item.id == value.id
  })
  if(index > -1) {
    state.citations[index] = value
  }
  else {
    state.citations.push(value)
  }
}