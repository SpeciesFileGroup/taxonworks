export default (state, args) => {
  const {
    rowObjectId,
    rowObjectType
  } = args
  state.rowObjects.find(o => o.id === rowObjectId && o.type === rowObjectType).hasSavedAtLeastOnce = true
}
