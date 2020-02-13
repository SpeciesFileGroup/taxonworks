import mergeIntoObservation from '../helpers/mergeIntoObservation'
import setDescriptorUnsaved from '../helpers/setDescriptorUnsaved'

export default function (state, args) {
  const {
    descriptorId,
    median
  } = args

  mergeIntoObservation(state.observations.find(o => o.descriptorId === descriptorId), { median })
  setDescriptorUnsaved(state.descriptors.find(d => d.id === descriptorId))
};
