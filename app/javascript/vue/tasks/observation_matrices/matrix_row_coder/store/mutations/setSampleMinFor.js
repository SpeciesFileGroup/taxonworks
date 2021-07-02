import mergeIntoObservation from '../helpers/mergeIntoObservation'
import setDescriptorUnsaved from '../helpers/setDescriptorUnsaved'

export default function (state, args) {
  const {
    descriptorId,
    min
  } = args

  mergeIntoObservation(state.observations.find(o => o.descriptorId === descriptorId), { min })
  setDescriptorUnsaved(state.descriptors.find(d => d.id === descriptorId))
};
