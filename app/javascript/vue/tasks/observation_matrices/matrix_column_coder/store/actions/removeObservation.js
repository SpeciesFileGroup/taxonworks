import ComponentNames from '../../helpers/ComponentNames'
import ObservationTypes from '../../helpers/ObservationTypes'
import { MutationNames } from '../mutations/mutations'
import { Observation } from 'routes/endpoints'

export default function ({ commit, state }, args) {
  const {
    rowObjectId,
    rowObjectType,
    characterStateId = null,
    obsId = null
  } = args

  const observationId = findObservationId()

  commit(MutationNames.SetRowObjectSaving, {
    rowObjectId,
    rowObjectType,
    isSaving: true
  })

  return Observation.destroy(observationId)
    .then(_ => {
      removeObservation()
      commit(MutationNames.SetRowObjectSaving, {
        rowObjectId,
        rowObjectType,
        isSaving: false
      })
      commit(MutationNames.SetRowObjectUnsaved, {
        rowObjectId,
        rowObjectType,
        isUnsaved: false
      })
      commit(MutationNames.SetRowObjectSavedOnce, {
        rowObjectId,
        rowObjectType
      })
    })

  function findObservationId () {
    return state.observations.find(getFindCallback()).id
  }

  function getFindCallback () {
    if (state.descriptor.type === ComponentNames.Qualitative) {
      return o => o.rowObjectId === rowObjectId && o.rowObjectType === rowObjectType && o.characterStateId === characterStateId
    } else if (state.descriptor.type === ComponentNames.Continuous) {
      return o => o.rowObjectId === rowObjectId && o.rowObjectType === rowObjectType && o.id === obsId
    } else if (state.descriptor.type === ComponentNames.Sample) {
      return o => o.rowObjectId === rowObjectId && o.rowObjectType === rowObjectType && o.id === obsId
    } else if (state.descriptor.type === ComponentNames.Media) {
      return o => o.rowObjectId === rowObjectId && o.rowObjectType === rowObjectType && o.id === obsId
    } else {
      return o => o.rowObjectId === rowObjectId && o.rowObjectType === rowObjectType
    }
  }

  function removeObservation () {
    if (
      state.descriptor.type === ComponentNames.Continuous ||
      state.descriptor.type === ComponentNames.Sample
    ) {
      const observationList = getObservationListByRow(state.descriptor.type)

      if (observationList.length > 1) {
        commit(MutationNames.RemoveObservation, obsId)
      } else {
        commit(MutationNames.CleanObservation, observationId)
      }
    } else {
      commit(MutationNames.CleanObservation, observationId)
    }
  }

  function getObservationListByRow (type) {
    if (type === ComponentNames.Continuous) {
      return state.observations.filter(o => o.type === ObservationTypes.Continuous && o.rowObjectId === rowObjectId && o.rowObjectType === rowObjectType)
    } else if (type === ComponentNames.Sample) {
      return state.observations.filter(o => o.type === ObservationTypes.Sample && o.rowObjectId === rowObjectId && o.rowObjectType === rowObjectType)
    }
  }
}
