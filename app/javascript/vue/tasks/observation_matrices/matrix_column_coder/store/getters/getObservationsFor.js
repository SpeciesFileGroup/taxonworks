export default function (state) {
  return ({ rowObjectId, rowObjectType }) => state.observations.filter(o => o.rowObjectId === rowObjectId && o.rowObjectType === rowObjectType)
}
