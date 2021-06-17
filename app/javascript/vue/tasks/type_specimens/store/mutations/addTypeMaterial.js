export default (state, material) => {
  const position = state.type_materials.findIndex(item => item.id === material.id)

  if (position < 0) {
    state.type_materials.push(material)
  } else {
    state.type_materials[position] = material
  }
}
