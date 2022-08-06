export default function (state, { rowObjectId, rowObjectType }) {
  state.rowObjects.find(r => r.id === rowObjectId && r.type === rowObjectType).needsCountdown = false
}
