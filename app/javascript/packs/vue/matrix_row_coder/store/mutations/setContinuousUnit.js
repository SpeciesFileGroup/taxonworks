import mergeIntoObservation from '../helpers/mergeIntoObservation'
import setDescriptorUnsaved from '../helpers/setDescriptorUnsaved'

export default function (state, args) {
  const {
    descriptorId,
    continuousUnit
  } = args

  mergeIntoObservation(state.observations.find(o => o.descriptorId === descriptorId), { continuousUnit })
  setDescriptorUnsaved(state.descriptors.find(d => d.id === descriptorId))
};
