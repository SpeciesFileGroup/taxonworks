import transformDepictionForViewmodel from '../helpers/transformDepictionForViewmodel'

export default function (state, args) {
  const observation = state.observations.find(o => o.id === args.observationId)
  observation.depictions = args.depictions.map(transformDepictionForViewmodel)
};
