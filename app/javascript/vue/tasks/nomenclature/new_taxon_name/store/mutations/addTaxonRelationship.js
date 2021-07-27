export default (state, relationship) => {
  const position = state.taxonRelationshipList.findIndex(item => item.id === relationship.id)

  if (position < 0) {
    state.taxonRelationshipList.push(relationship)
  } else {
    state.taxonRelationshipList[position] = relationship
  }
}
