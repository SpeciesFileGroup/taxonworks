export default function (state, relationship) {
  var position = state.taxonRelationshipList.findIndex(item => {
    if (item.type == relationship.type) {
      return true
    }
  })
  if (position >= 0) {
    state.taxonRelationshipList.splice(position, 1)
  }
}
