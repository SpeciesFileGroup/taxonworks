import transformNoteForViewmodel from '../helpers/transformNoteForViewmodel'

export default function (state, args) {
  const observation = state.observations.find(o => o.id === args.observationId)
  observation.notes = args.notes.map(transformNoteForViewmodel)
};
