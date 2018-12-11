export default function (state) {
  return descriptorId => state.observations.find(o => o.descriptorId === descriptorId).median
};
