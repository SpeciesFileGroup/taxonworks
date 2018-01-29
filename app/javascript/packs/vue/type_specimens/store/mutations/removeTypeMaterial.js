export default function (state, id) {
  var position = state.type_materials.findIndex(item => {
    if (item.id == id) {
      return true
    }
  })
  if (position >= 0) {
    state.type_materials.splice(position, 1)
  }
};
