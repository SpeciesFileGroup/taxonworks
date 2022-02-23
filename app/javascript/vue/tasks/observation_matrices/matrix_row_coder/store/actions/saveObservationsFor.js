import ActionNames from './actionNames'
import { MutationNames } from '../mutations/mutations'
import ObservationTypes from '../helpers/ObservationTypes'

export default function ({ dispatch, state, commit }, descriptorId) {
  const observations = state.observations
    .filter(o => o.descriptorId === descriptorId && o.isUnsaved)

  console.log(observations)
  return Promise.all(observations.map(o => {
    if (!isUpdatableObservation(o)) {
      saveUnupdatableObservation(o)
    } else if (o.id) {
      return dispatch(ActionNames.UpdateObservation, { descriptorId, observationId: o.id })
    } else {
      return dispatch(ActionNames.CreateObservation, { descriptorId, internalId: o.internalId })
    }
  }))

  function saveUnupdatableObservation (observation) {
    if (observation.id && !observation.isChecked) { 
      return dispatch(ActionNames.RemoveObservation, makeObservationArgs(observation)) 
    } else if (observation.isChecked) { 
      return dispatch(ActionNames.CreateObservation, makeObservationArgs(observation)) 
    } else { 
      commit(MutationNames.ObservationSaved, makeObservationArgs(observation))
    }
  }
};

function isUpdatableObservation (observation) {
  return observation.type !== ObservationTypes.Qualitative
}

function makeObservationArgs (observation) {
  const args = {
    descriptorId: observation.descriptorId
  }

  if (observation.type === ObservationTypes.Qualitative) { args.characterStateId = observation.characterStateId }

  return args
}
