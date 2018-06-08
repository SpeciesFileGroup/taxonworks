import transformNoteForViewmodel from '../helpers/transformNoteForViewmodel'

export default function (state, args) {
  state.descriptors.find(d => d.id === args.descriptorId)
    .notes = args.notes.map(transformNoteForViewmodel)
};
