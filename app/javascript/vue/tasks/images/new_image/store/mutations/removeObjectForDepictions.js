export default function(state, value) {
  let index = state.objectsForDepictions.findIndex(item => {
    return (item.id == value.id && item.base_class == value.base_class)
  })
  if(index > -1) {
    state.objectsForDepictions.splice(index, 1)
  }
}