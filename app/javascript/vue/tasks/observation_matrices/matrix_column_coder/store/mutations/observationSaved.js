import ComponentNames from '../../helpers/ComponentNames'

export default function (state, args) {
  const { characterStateId = null, rowObjectId, rowObjectType } = args

  const descriptor = state.descriptor

  if (descriptor.componentName === ComponentNames.Qualitative) {
    const observation = state.observations.find((o) => {
      return (
        o.characterStateId === characterStateId &&
          o.rowObjectType === rowObjectType,
        o.rowObjectId === rowObjectId
      )
    })
    observation.isUnsaved = false
  } else {
    state.observations.find(
      (o) => o.rowObjectId === rowObjectId && o.rowObjectType === rowObjectType
    ).isUnsaved = false
  }
}
