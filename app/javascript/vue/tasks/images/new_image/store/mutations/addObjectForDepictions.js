export default function(state, value) {
  let index = state.objectsForDepictions.findIndex(item => {
    return (item.id == value.id && item.base_class == value.base_class)
  })
  if(index < 0) {
    state.objectsForDepictions.push(value)
  }
}