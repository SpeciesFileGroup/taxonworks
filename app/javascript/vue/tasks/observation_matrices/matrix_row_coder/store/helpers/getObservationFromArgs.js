import ComponentNames from '../helpers/ComponentNames'

export default function (state, args) {
  const {
    descriptorId,
    characterStateId = null,
    internalId
  } = args

  const descriptor = state.descriptors.find(d => d.id === descriptorId)

  if (descriptor.componentName === ComponentNames.Qualitative) {
    return state.observations.find(o => o.characterStateId === characterStateId && o.descriptorId === descriptorId)
  } else if (descriptor.componentName === ComponentNames.Continuous) {
    return state.observations.find(o => o.internalId === internalId && o.descriptorId === descriptorId)
  } else if (descriptor.componentName === ComponentNames.Sample) {
    return state.observations.find(o => o.internalId === internalId && o.descriptorId === descriptorId)
  } else {
    return state.observations.find(o => o.descriptorId === descriptorId)
  }
}
