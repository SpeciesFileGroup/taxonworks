import baseCRUD from './base'

const permitParams = {
  documentation: {
    documentation_object_id: Number,
    documentation_object_type: String,
    document_id: Number,
    annotated_global_entity: String,
    position: Number,
    document_attributes: {
      document_file: String,
      is_public: Boolean
    }
  }
}

export const Documentation = {
  ...baseCRUD('documentation', permitParams)
}
