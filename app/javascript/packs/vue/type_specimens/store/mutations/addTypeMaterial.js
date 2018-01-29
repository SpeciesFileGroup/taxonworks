import Vue from 'vue'

export default function (state, material) {
  var position = state.type_materials.findIndex(item => {
    if (item.id == material.id) {
      return true
    }
  })
  if (position < 0) {
    state.type_materials.push(material)
  } else {
    Vue.set(state.type_materials, position, material)
  }
};
