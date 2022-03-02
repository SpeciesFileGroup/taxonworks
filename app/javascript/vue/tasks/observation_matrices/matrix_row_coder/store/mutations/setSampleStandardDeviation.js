import mergeIntoObservation from '../helpers/mergeIntoObservation'
import setDescriptorUnsaved from '../helpers/setDescriptorUnsaved'

export default function (state, args) {
  const {
    descriptorId,
    observationId,
    standardDeviation
  } = args

  mergeIntoObservation(state.observations.find(o => o.descriptorId === descriptorId && (o.id === observationId || o.internalId === observationId)), { standardDeviation, isUnsaved: true })
  setDescriptorUnsaved(state.descriptors.find(d => d.id === descriptorId))
};
