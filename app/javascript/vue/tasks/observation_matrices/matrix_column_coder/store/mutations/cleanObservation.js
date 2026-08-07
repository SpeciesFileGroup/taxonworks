import ComponentNames from '../../helpers/ComponentNames'
import makeEmptyObservationsFor from '../../helpers/makeEmptyObservationsFor'

export default function (state, observationId) {
  const observationIndex = state.observations.findIndex(o => o.id === observationId)
  const rowObjectId = state.observations[observationIndex].rowObjectId
  const rowObject = state.rowObjects.find(d => d.id === rowObjectId)

  if (state.descriptor.componentName === ComponentNames.Qualitative) {
    const characterStateId = state.observations[observationIndex].characterStateId
    const emptyObservations = makeEmptyObservationsFor(state.descriptor, rowObject)

    Object.assign(state.observations[observationIndex], emptyObservations.find(o => o.characterStateId === characterStateId))
  } else {
    Object.assign(state.observations[observationIndex], makeEmptyObservationsFor(state.descriptor, rowObject)[0])
  }
}
