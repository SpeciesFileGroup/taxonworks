import ComponentNames from '../helpers/ComponentNames'

export default function (state, args) {
  const {
    rowObjectId,
    rowObjectType,
    characterStateId = null,
    internalId
  } = args

  const descriptor = state.descriptor

  if (descriptor.componentName === ComponentNames.Qualitative) {
    return state.observations.find(o => o.characterStateId === characterStateId && o.rowObjectId === rowObjectId && o.rowObjectType === rowObjectType)
  } else if (descriptor.componentName === ComponentNames.Continuous) {
    return state.observations.find(o => o.internalId === internalId && o.rowObjectId === rowObjectId && o.rowObjectType === rowObjectType)
  } else if (descriptor.componentName === ComponentNames.Sample) {
    return state.observations.find(o => o.internalId === internalId && o.rowObjectId === rowObjectId && o.rowObjectType === rowObjectType)
  } else {
    return state.observations.find(o => o.rowObjectId === rowObjectId && o.rowObjectType === rowObjectType)
  }
}
