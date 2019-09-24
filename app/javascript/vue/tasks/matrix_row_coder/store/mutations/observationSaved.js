import ComponentNames from '../helpers/ComponentNames'

export default function (state, args) {
  const {
    descriptorId,
    characterStateId = null
  } = args

  const descriptor = state.descriptors.find(d => d.id === descriptorId)

  if (descriptor.componentName === ComponentNames.Qualitative) {
    const observation = state.observations.find(o => {
      return o.characterStateId === characterStateId && o.descriptorId === descriptorId
    })
    observation.isUnsaved = false
  } else { state.observations.find(o => o.descriptorId === descriptorId).isUnsaved = false }
};
