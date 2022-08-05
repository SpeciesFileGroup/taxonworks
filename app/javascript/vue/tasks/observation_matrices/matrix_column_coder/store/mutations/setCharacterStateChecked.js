import mergeIntoObservation from '../../helpers/mergeIntoObservation'
import setRowObjectUnsaved from '../../helpers/setRowObjectUnsaved'

export default function (state, args) {
  const {
    rowObjectId,
    rowObjectType,
    characterStateId,
    isChecked
  } = args

  const observation = state.observations
    .find(o =>
      o.rowObjectId === rowObjectId &&
      o.rowObjectType === rowObjectType &&
      o.characterStateId === characterStateId)

  mergeIntoObservation(observation, { isChecked, isUnsaved: true })
  setRowObjectUnsaved(state.rowObjects.find(r => r.id === rowObjectId && r.type === rowObjectType))
}
