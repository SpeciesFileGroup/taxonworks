export default state =>
  rowObjectId => state.rowObjects.find(o => o.id === rowObjectId).isUnsaved
