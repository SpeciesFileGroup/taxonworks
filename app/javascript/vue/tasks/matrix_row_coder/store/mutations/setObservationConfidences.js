export default function (state, args) {
  const observation = state.observations.find(o => o.id === args.observationId)
  observation.confidences = args.confidences
};
