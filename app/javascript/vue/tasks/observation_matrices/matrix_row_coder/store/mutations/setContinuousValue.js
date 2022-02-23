import mergeIntoObservation from '../helpers/mergeIntoObservation'
import setDescriptorUnsaved from '../helpers/setDescriptorUnsaved'

export default function (state, args) {
  const {
    descriptorId,
    continuousValue,
    observationId
  } = args

  mergeIntoObservation(state.observations.find(o => o.descriptorId === descriptorId && (o.id === observationId || o.internalId === observationId)), { 
    continuousValue,
    isUnsaved: true
  })
  setDescriptorUnsaved(state.descriptors.find(d => d.id === descriptorId))
}
