import mergeIntoObservation from '../../helpers/mergeIntoObservation'
import setRowObjectUnsaved from '../../helpers/setRowObjectUnsaved'

export default function (state, args) {
  const {
    rowObjectId,
    rowObjectType,
    observationId,
    max
  } = args

  const observation = state.observations.find(o =>
    o.rowObjectId === rowObjectId &&
    o.rowObjectType === rowObjectType &&
    (o.id === observationId || o.internalId === observationId)
  )

  mergeIntoObservation(observation, { max, isUnsaved: true })
  setRowObjectUnsaved(state.rowObjects.find(r => r.id === rowObjectId && r.type === rowObjectType))
}
