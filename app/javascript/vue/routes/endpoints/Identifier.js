import baseCRUD from './base'

const permitParams = {
  identifier: {
    id: Number,
    identifier_object_id: Number,
    identifier_object_type: String,
    identifier: String,
    type: String,
    namespace_id: Number,
    annotated_global_entity: String
  }
}

export const Identifier = {
  ...baseCRUD('identifiers', permitParams)
}
