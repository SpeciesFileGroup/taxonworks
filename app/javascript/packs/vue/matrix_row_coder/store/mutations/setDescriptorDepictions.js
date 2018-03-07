import transformDepictionForViewmodel from '../helpers/transformDepictionForViewmodel'

export default function (state, args) {
  const descriptor = state.descriptors.find(d => d.id === args.descriptorId)
  descriptor.depictions = args.depictions.map(transformDepictionForViewmodel)
};
