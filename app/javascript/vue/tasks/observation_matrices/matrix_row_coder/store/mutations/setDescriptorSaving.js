export default function (state, args) {
  const {
    descriptorId,
    isSaving
  } = args
  state.descriptors.find(d => d.id === descriptorId).isSaving = !!isSaving
};
