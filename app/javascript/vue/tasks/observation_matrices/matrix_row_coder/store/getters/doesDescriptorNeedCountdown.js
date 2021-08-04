export default state =>
  descriptorId => state.descriptors.find(d => d.id === descriptorId)?.needsCountdown
