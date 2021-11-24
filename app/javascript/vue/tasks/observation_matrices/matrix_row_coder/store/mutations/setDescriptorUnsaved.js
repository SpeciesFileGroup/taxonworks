export default (state, args) => {
  const {
    descriptorId,
    isUnsaved
  } = args
  state.descriptors.find(d => d.id === descriptorId).isUnsaved = !!isUnsaved
}
