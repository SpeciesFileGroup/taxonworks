export default function (state) {
  return args => {
    const { descriptorId, characterStateId } = args
    const observation = state.observations.find(o => o.descriptorId === descriptorId && o.characterStateId === characterStateId)
    return observation.isChecked
  }
};
