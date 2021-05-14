import baseCRUD from './base'

const permitParams = {
  protocol_relationship: {
    protocol_id: Number,
    protocol_relationship_object_id: Number,
    protocol_relationship_object_type: String,
    annotated_global_entity: String
  }
}

export const ProtocolRelationship = {
  ...baseCRUD('protocol_relationships', permitParams),
}
