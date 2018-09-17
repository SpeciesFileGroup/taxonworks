import ObservationTypes from '../helpers/ObservationTypes'

export default function (state, observation) {
  if (!observation.type) { throw `Observations must have a type!` }

  if (Object.keys(ObservationTypes).findIndex(typeKey => ObservationTypes[typeKey] === observation.type) === -1) { throw `Observations must have a valid type! Given ${observation.type}` }

  if (!state.descriptors.find(d => d.id === observation.descriptorId)) { throw `Observations must have a matching descriptor!` }

  if (observation.type === ObservationTypes.Qualitative && !observation.characterStateId) { throw `Qualitative Observations must have a character state id!` }

  let existingObservation
  if (observation.type !== ObservationTypes.Qualitative) { existingObservation = state.observations.find(o => o.descriptorId === observation.descriptorId) } else { existingObservation = state.observations.find(o => o.descriptorId === observation.descriptorId && o.characterStateId === observation.characterStateId) }

  if (existingObservation) { Object.assign(existingObservation, observation) } else { state.observations.push(observation) }
};
