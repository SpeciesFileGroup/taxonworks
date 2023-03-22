import baseCRUD from './base'

const permitParams = {
  note: {
    id: Number,
    text: String,
    note_object_id: Number,
    note_object_type: String,
    note_object_attribute: String,
    annotated_global_entity: String
  }
}

export const Note = {
  ...baseCRUD('notes', permitParams)
}
