import makeBaseObservation from './makeBaseObservation'

export default function (observationData) {
  const observation = makeBaseObservation(observationData)
  return Object.assign(observation, {
    characterStateId: observationData.characterStateId || observationData.character_state_id,
    isChecked: !!observationData.id
  })
}
