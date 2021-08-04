import baseCRUD from './base'

const permitParams = {
  label: {
    text: String,
    total: Number,
    style: String,
    is_copy_edited: Boolean,
    is_printed: Boolean,
    type: String,
    label_object_id: Number,
    label_object_type: String,
    annotated_global_entity: String
  }
}

export const Label = {
  ...baseCRUD('labels', permitParams)
}
