import baseCRUD from './base'

const permitParams = {
  data_attribute: {
    annotated_global_entity: String,
    attribute_subject_id: Number,
    attribute_subject_type: String,
    controlled_vocabulary_term_id: Number,
    import_predicate: String,
    type: String,
    value: String
  }
}

export const DataAttribute = {
  ...baseCRUD('data_attributes', permitParams)
}
