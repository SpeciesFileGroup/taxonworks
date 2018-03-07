export default function (state, args) {
  const {
    descriptorId,
    isZoomed
  } = args

  const descriptor = state.descriptors.find(d => d.id === descriptorId)
  descriptor.isZoomed = isZoomed

  attemptUnzoomOtherDescriptors()

  function attemptUnzoomOtherDescriptors () {
    if (isZoomed) {
      state.descriptors.forEach(descriptor => {
        if (descriptor.id !== descriptorId) { descriptor.isZoomed = false }
      })
    }
  }
};
