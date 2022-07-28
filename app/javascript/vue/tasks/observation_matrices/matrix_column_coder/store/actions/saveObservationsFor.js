import ActionNames from './actionNames'
import { MutationNames } from '../mutations/mutations'
import ObservationTypes from '../../helpers/ObservationTypes'

export default function ({ dispatch, state, commit }, { rowObjectId, rowObjectType }) {
  const observations = state.observations.filter(o => o.isUnsaved)

  return Promise.all(observations.map(o => {
    if (isQualitativeObservation(o)) {
      saveQualitativeObservation(o)
    } else if (o.id) {
      return dispatch(ActionNames.UpdateObservation, { rowObjectId, rowObjectType, observationId: o.id })
    } else {
      return dispatch(ActionNames.CreateObservation, { rowObjectId, rowObjectType, internalId: o.internalId })
    }
  }))

  function saveQualitativeObservation (observation) {
    if (observation.id && !observation.isChecked) {
      return dispatch(ActionNames.RemoveObservation, makeObservationArgs(observation))
    } else if (observation.isChecked && observation.id) {
      return dispatch(ActionNames.UpdateObservation, makeObservationArgs(observation))
    } else if (observation.isChecked) {
      return dispatch(ActionNames.CreateObservation, makeObservationArgs(observation))
    } else {
      commit(MutationNames.ObservationSaved, makeObservationArgs(observation))
    }
  }
}

function isQualitativeObservation (observation) {
  return observation.type === ObservationTypes.Qualitative
}

function makeObservationArgs (observation) {
  const args = {
    descriptorId: observation.descriptorId,
    observationId: observation.id || observation.internalId,
    characterStateId: observation.characterStateId,
    rowObjectId: observation.rowObjectId,
    rowObjectType: observation.rowObjectType
  }

  return args
}
