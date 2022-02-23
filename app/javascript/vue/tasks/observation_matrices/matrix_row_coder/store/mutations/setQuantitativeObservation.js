import mergeIntoObservation from '../helpers/mergeIntoObservation'
import setDescriptorUnsaved from '../helpers/setDescriptorUnsaved'

export default function (state, args) {
  const {
    descriptorId,
    observationId,
    continuousValue,
    units
  } = args

  const observation = state.observations
    .find(o => o.descriptorId === descriptorId && o.id === observationId)

  mergeIntoObservation(observation, { continuousValue, units })
  setDescriptorUnsaved(state.descriptors.find(d => d.id === descriptorId))
}
