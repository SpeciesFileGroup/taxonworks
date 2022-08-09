import ObservationTypes from '../../helpers/ObservationTypes'

export default function (state, observation) {
  if (!observation.type) { throw `Observations must have a type!` }

  if (Object.keys(ObservationTypes).findIndex(typeKey => ObservationTypes[typeKey] === observation.type) === -1) { throw `Observations must have a valid type! Given ${observation.type}` }

  if (observation.type === ObservationTypes.Qualitative && !observation.characterStateId) { throw `Qualitative Observations must have a character state id!` }

  const observations = state.observations.filter(o => o.rowObjectId === observation.rowObjectId && o.rowObjectType === observation.rowObjectType)
  let existingObservation

  if (observation.type === ObservationTypes.FreeText) {
    existingObservation = observations.find(o => o.rowObjectId === observation.rowObjectId)
  } else if (observation.type === ObservationTypes.Qualitative) {
    existingObservation = observations.find(o => o.characterStateId === observation.characterStateId)
  } else {
    existingObservation = getObservation(observation)
  }

  if (existingObservation) {
    Object.assign(existingObservation, observation)
  } else {
    state.observations.push(observation)
  }

  function getObservation (observation) {
    if (observations.length) {
      const o = observations.find(o => o.id === observation.id)

      if (o) { return o }

      if (observations.length === 1) {
        return !observations[0].id && observations[0]
      }
    }

    return false
  }
}
