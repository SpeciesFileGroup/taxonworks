import Vue from 'vue'

export default function (state, relationship) {

  var position = state.taxonRelationshipList.findIndex(item => {
    if (item.id == relationship.id) {
      return true
    }
  })

  if (position < 0) {
    state.taxonRelationshipList.push(relationship)
  } else {
    Vue.set(state.taxonRelationshipList, position, relationship)
  }
}
