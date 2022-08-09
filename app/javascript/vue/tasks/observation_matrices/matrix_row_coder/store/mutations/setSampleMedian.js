import mergeIntoObservation from '../helpers/mergeIntoObservation'
import setDescriptorUnsaved from '../helpers/setDescriptorUnsaved'

export default function (state, args) {
  const {
    descriptorId,
    observationId,
    median
  } = args

  mergeIntoObservation(state.observations.find(o => o.descriptorId === descriptorId && (o.id === observationId || o.internalId === observationId)), { median, isUnsaved: true })
  setDescriptorUnsaved(state.descriptors.find(d => d.id === descriptorId))
};
