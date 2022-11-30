export default function (state) {
  return args => {
    const {
      rowObjectId,
      rowObjectType,
      characterStateId
    } = args

    const observation = state.observations.find(o =>
      o.rowObjectId === rowObjectId &&
      o.rowObjectType === rowObjectType &&
      o.characterStateId === characterStateId
    )

    return observation.isChecked
  }
}
