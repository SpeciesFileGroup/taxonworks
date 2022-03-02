import ComponentNames from '../helpers/ComponentNames'
import ObservationTypes from '../helpers/ObservationTypes'
import { MutationNames } from '../mutations/mutations'

export default function ({ commit, state }, args) {
  const {
    descriptorId,
    characterStateId = null,
    obsId = null
  } = args

  const descriptor = state.descriptors.find(d => d.id === descriptorId)
  const observationId = findObservationId()

  commit(MutationNames.SetDescriptorSaving, {
    descriptorId,
    isSaving: true
  })

  return state.request.removeObservation(observationId)
    .then(_ => {
      removeObservation()
      commit(MutationNames.SetDescriptorSaving, {
        descriptorId,
        isSaving: false
      })
      commit(MutationNames.SetDescriptorUnsaved, {
        descriptorId,
        isUnsaved: false
      })
      commit(MutationNames.SetDescriptorSavedOnce, descriptorId)
    })

  function findObservationId () {
    return state.observations.find(getFindCallback()).id
  }

  function getFindCallback () {
    if (descriptor.type === ComponentNames.Qualitative) {
      return o => o.descriptorId === descriptorId && o.characterStateId === characterStateId
    } else if (descriptor.type === ComponentNames.Continuous) {
      return o => o.descriptorId === descriptorId && o.id === obsId
    } else if (descriptor.type === ComponentNames.Sample) {
      return o => o.descriptorId === descriptorId && o.id === obsId
    } else {
      return o => o.descriptorId === descriptorId
    }
  }

  function removeObservation () {
    if (
      descriptor.type === ComponentNames.Continuous ||
      descriptor.type === ComponentNames.Sample
    ) {
      const descriptorObservations = getObservationListByType(descriptor.type)

      if (descriptorObservations.length > 1) {
        commit(MutationNames.RemoveObservation, obsId)
      } else {
        commit(MutationNames.ClearObservation, observationId)
      }
    } else {
      commit(MutationNames.ClearObservation, observationId)
    }
  }

  function getObservationListByType (type) {
    if (type === ComponentNames.Continuous) {
      return state.observations.filter(o => o.type === ObservationTypes.Continuous && o.descriptorId === descriptor.id)
    } else if (type === ComponentNames.Sample) {
      return state.observations.filter(o => o.type === ObservationTypes.Sample && o.descriptorId === descriptor.id)
    }
  }
};
