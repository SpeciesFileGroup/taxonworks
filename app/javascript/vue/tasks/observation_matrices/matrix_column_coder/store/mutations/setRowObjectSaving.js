export default (state, args) => {
  const {
    rowObjectId,
    rowObjectType,
    isSaving
  } = args
  state.rowObjects.find(o => o.id === rowObjectId && o.type === rowObjectType).isSaving = !!isSaving
}
