export default function(state, id) {
  let index = state.materialTypes.findIndex((item) => {
    return item.id == id
  })
  state.materialTypes.splice(index, 1)
}