export default function(state, value) {
  let index = state.depictionsCreated.findIndex(item => {
    return item.id == value.id
  })
  if(index > -1) {
    state.depictionsCreated[index] = value
  }
  else {
    state.depictionsCreated.push(value)
  }
}