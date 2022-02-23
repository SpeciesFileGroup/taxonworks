import mergeIntoObservation from '../helpers/mergeIntoObservation'
import setDescriptorUnsaved from '../helpers/setDescriptorUnsaved'

export default function (state, args) {
  const {
    descriptorId,
    standardError
  } = args

  mergeIntoObservation(state.observations.find(o => o.descriptorId === descriptorId), { standardError, isUnsaved: true })
  setDescriptorUnsaved(state.descriptors.find(d => d.id === descriptorId))
};
