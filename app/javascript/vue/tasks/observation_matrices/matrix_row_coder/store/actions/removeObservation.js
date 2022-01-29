import ComponentNames from '../helpers/ComponentNames'
import { MutationNames } from '../mutations/mutations'

export default function ({ commit, state }, args) {
  const {
    descriptorId,
    characterStateId = null
  } = args

  const descriptor = state.descriptors.find(d => d.id === descriptorId)
  const observationId = findObservationId()

  commit(MutationNames.SetDescriptorSaving, {
    descriptorId,
    isSaving: true
  })

  return state.request.removeObservation(observationId)
    .then(_ => {
      commit(MutationNames.ClearObservation, observationId)
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
    return descriptor.type === ComponentNames.Qualitative
      ? o => o.descriptorId === descriptorId && o.characterStateId === characterStateId
      : o => o.descriptorId === descriptorId
  }
};
