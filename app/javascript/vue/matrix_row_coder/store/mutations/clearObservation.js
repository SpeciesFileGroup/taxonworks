import ComponentNames from '../helpers/ComponentNames'
import makeEmptyObservationsFor from '../helpers/makeEmptyObservationsFor'

export default function (state, observationId) {
  const observationIndex = state.observations.findIndex(o => o.id === observationId)
  const descriptorId = state.observations[observationIndex].descriptorId
  const descriptor = state.descriptors.find(d => d.id === descriptorId)

  if (descriptor.componentName === ComponentNames.Qualitative) {
    const characterStateId = state.observations[observationIndex].characterStateId
    const emptyObservations = makeEmptyObservationsFor(descriptor)
    Object.assign(state.observations[observationIndex], emptyObservations.find(o => o.characterStateId === characterStateId))
  } else { Object.assign(state.observations[observationIndex], makeEmptyObservationsFor(descriptor)[0]) }
};
