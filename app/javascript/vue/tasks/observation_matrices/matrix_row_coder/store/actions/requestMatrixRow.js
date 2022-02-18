import { MutationNames } from '../mutations/mutations'
import DescriptorTypes from '../helpers/DescriptorTypes'
import ComponentNames from '../helpers/ComponentNames'
import makeEmptyObservationsFor from '../helpers/makeEmptyObservationsFor'

export default function ({ commit, state }, rowId) {
  return state.request.getMatrixRow(rowId)
    .then(response => {
      const descriptors = response.descriptors.map(transformDescriptorForViewmodel)
      commit(MutationNames.SetDescriptors, descriptors)
      commit(MutationNames.SetMatrixRow, response)

      const emptyObservations = makeEmptyObservationsForDescriptors(descriptors)
      emptyObservations.forEach(o => commit(MutationNames.SetObservation, o))

      addOtuToState()

      function addOtuToState () {
        const {
          global_id,
          object_tag
        } = response.observation_object
        commit(MutationNames.SetTaxonId, global_id)
        commit(MutationNames.SetTaxonTitle, object_tag)
      }
    })
};

function transformDescriptorForViewmodel (descriptorData) {
  const descriptor = makeBaseDescriptor(descriptorData)
  attemptToAddCharacterStates(descriptorData, descriptor)
  attemptToAddDefaultUnit(descriptorData, descriptor)
  return descriptor
}

function makeBaseDescriptor (descriptorData) {
  return {
    id: descriptorData.id,
    componentName: getComponentNameForDescriptorType(descriptorData),
    title: descriptorData.object_tag,
    globalId: descriptorData.global_id,
    description: getDescription(descriptorData),
    type: getComponentNameForDescriptorType(descriptorData),
    isUnsaved: false,
    needsCountdown: false,
    isSaving: false,
    hasSavedAtLeastOnce: false,
    notes: null,
    depictions: null
  }
}

const DescriptorTypesToComponentNames = {
  [DescriptorTypes.FreeText]: ComponentNames.FreeText,
  [DescriptorTypes.Media]: ComponentNames.Media,
  [DescriptorTypes.Qualitative]: ComponentNames.Qualitative,
  [DescriptorTypes.Continuous]: ComponentNames.Continuous,
  [DescriptorTypes.Sample]: ComponentNames.Sample,
  [DescriptorTypes.Presence]: ComponentNames.Presence
}

function getComponentNameForDescriptorType (descriptorData) {
  return DescriptorTypesToComponentNames[descriptorData.type]
}

function getDescription (descriptorData) {
  return descriptorData.description || null
}

function attemptToAddCharacterStates (descriptorData, descriptor) {
  if (descriptor.componentName === ComponentNames.Qualitative) { descriptor.characterStates = descriptorData.character_states.map(transformCharacterStateForViewmodel) }
}

function attemptToAddDefaultUnit (descriptorData, descriptor) {
  if (descriptor.componentName === ComponentNames.Continuous || descriptor.componentName === ComponentNames.Sample) { descriptor.default_unit = descriptorData.default_unit }
}

function transformCharacterStateForViewmodel (characterStateData) {
  return {
    id: characterStateData.id,
    name: characterStateData.name,
    label: characterStateData.label,
    globalId: characterStateData.global_id,
    description: characterStateData.description || null
  }
}

function makeEmptyObservationsForDescriptors (descriptors) {
  let observations = []

  descriptors.forEach(descriptor => {
    observations = [...observations, ...makeEmptyObservationsFor(descriptor)]
  })

  return observations
}
