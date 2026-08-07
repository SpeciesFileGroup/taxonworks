import mergeIntoObservation from '../helpers/mergeIntoObservation'
import setDescriptorUnsaved from '../helpers/setDescriptorUnsaved'

export default function (state, args) {
  const {
    descriptorId,
    characterStateId,
    isChecked
  } = args

  const observation = state.observations
    .find(o => o.descriptorId === descriptorId && o.characterStateId === characterStateId)

  mergeIntoObservation(observation, { isChecked, isUnsaved: true })
  setDescriptorUnsaved(state.descriptors.find(d => d.id === descriptorId))
};
