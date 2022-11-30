export default state => {
  const {
    descriptor,
    rowObjects,
    observations
  } = state

  const {
    showOnlyUnscoredRows,
    showScoredCharacterStates
  } = state.options

  const rowObjectIdsWithObservations = showScoredCharacterStates.length
    ? getRowObjectIdsByCharacterStateCreated(observations, showScoredCharacterStates)
    : getRowObjectIdsByObservationCreated(observations)

  if (showScoredCharacterStates.length) {
    return rowObjects.filter(item => rowObjectIdsWithObservations.includes(item.id))
  }

  return showOnlyUnscoredRows
    ? rowObjects.filter(item => !rowObjectIdsWithObservations.includes(item.id))
    : rowObjects
}

function getRowObjectIdsByObservationCreated (observations) {
  const ids = []

  observations.forEach(({ id, rowObjectId }) => {
    if (id) {
      ids.push(rowObjectId)
    }
  })

  return ids
}

function getRowObjectIdsByCharacterStateCreated (observations, characterStates) {
  const ids = []

  observations.forEach(({ id, characterStateId, rowObjectId }) => {
    if (id && characterStates.includes(characterStateId)) {
      ids.push(rowObjectId)
    }
  })

  return ids
}
