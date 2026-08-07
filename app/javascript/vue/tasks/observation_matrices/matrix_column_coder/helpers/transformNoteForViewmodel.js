export default function transformNoteForViewmodel (note) {
  return {
    text: note.text,
    noteIsFor: note.note_object_id,
    noteIsForA: note.note_object_type
  }
}
