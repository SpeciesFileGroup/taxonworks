export default function (state) {
  return descriptorId => state.observations.filter(o => o.descriptorId === descriptorId)
};
