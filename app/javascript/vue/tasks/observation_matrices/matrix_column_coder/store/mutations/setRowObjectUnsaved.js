export default (state, args) => {
  const {
    rowObjectId,
    rowObjectType,
    isUnsaved
  } = args
  state.rowObjects.find(o => o.id === rowObjectId && o.type === rowObjectType).isUnsaved = !!isUnsaved
}
