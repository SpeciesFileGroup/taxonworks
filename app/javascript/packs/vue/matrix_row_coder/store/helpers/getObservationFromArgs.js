import ComponentNames from '../helpers/ComponentNames'

export default function (state, args) {
  const {
    descriptorId,
    characterStateId = null
  } = args

  const descriptor = state.descriptors.find(d => d.id === descriptorId)

  if (descriptor.componentName === ComponentNames.Qualitative) {
    return state.observations.find(o => {
      return o.characterStateId === characterStateId && o.descriptorId === descriptorId
    })
  } else { return state.observations.find(o => o.descriptorId === descriptorId) }
};
