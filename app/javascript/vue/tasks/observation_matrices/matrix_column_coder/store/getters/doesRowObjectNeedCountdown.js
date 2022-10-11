export default state =>
  rowObjectId => state.rowObjects.find(d => d.id === rowObjectId)?.needsCountdown
