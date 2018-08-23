export default function (state, descriptorId) {
  state.descriptors.find(d => d.id === descriptorId).needsCountdown = false
};
