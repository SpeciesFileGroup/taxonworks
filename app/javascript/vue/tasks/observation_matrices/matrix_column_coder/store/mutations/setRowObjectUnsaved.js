export default (state, args) => {
  const {
    rowObjectId,
    isUnsaved
  } = args
  state.rowObjects.find(o => o.id === rowObjectId).isUnsaved = !!isUnsaved
}
