export default function(state, value) {
  let index = state.attributionsCreated.findIndex(item => {
    return item.id == value.id
  })
  if(index > -1) {
    state.attributionsCreated[index] = value
  }
  else {
    state.attributionsCreated.push(value)
  }
}