import mergeIntoObservation from '../../helpers/mergeIntoObservation'
import setRowObjectUnsaved from '../../helpers/setRowObjectUnsaved'

export default function (state, args) {
  const {
    rowObjectId,
    rowObjectType,
    isChecked
  } = args

  const observation = state.observations.find(o =>
    o.rowObjectId === rowObjectId &&
    o.rowObjectType === rowObjectType
  )

  mergeIntoObservation(observation, { isChecked, isUnsaved: true })
  setRowObjectUnsaved(state.rowObjects.find(r => r.id === rowObjectId && r.type === rowObjectType))
}
