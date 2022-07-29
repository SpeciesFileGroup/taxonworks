import mergeIntoObservation from '../../helpers/mergeIntoObservation'
import setRowObjectUnsaved from '../../helpers/setRowObjectUnsaved'

export default function (state, args) {
  const {
    rowObjectId,
    rowObjectType,
    observationId,
    standardDeviation
  } = args

  const observation = state.observations.find(o =>
    o.rowObjectId === rowObjectId &&
    o.rowObjectType === rowObjectType &&
    (o.id === observationId || o.internalId === observationId)
  )

  mergeIntoObservation(observation, { standardDeviation, isUnsaved: true })
  setRowObjectUnsaved(state.rowObjects.find(r => r.id === rowObjectId && r.type === rowObjectType))
}
