export default function (state) {
  return ({ rowObjectId, rowObjectType }) => state.observations.find(o => o.rowObjectId === rowObjectId && o.rowObjectType === rowObjectType).description
}
