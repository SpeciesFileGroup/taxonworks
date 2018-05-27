export default function (state) {
  return descriptorId => state.descriptors.find(d => d.id === descriptorId).isSaving
}