export default function (state) {
  return descriptorId => {
    const observation = state.observations.find(o => o.descriptorId === descriptorId)
    return observation && observation.hasOwnProperty('continuousValue') ? observation.continuousValue : null
  }
};
