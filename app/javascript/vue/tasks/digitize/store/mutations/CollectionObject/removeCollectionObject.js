export default function(state, value) {
  let index = state.collection_objects.findIndex((item) => {
    return item.id == value.id
  })
  if(index >= 0) {
    state.collection_objects.splice(index, 1)
  }
}