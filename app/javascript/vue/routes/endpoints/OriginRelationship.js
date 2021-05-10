import baseCRUD, { annotations } from './base'

const permitParams = {
  origin_relationship: {
    old_object_id: Number,
    old_object_type: String,
    new_object_id: Number,
    new_object_type: String,
    position: Number,
    created_by_id: Number,
    updated_by_id: Number,
    project_id: Number
  }
}

export const OriginRelationship = {
  ...baseCRUD('origin_relationships', permitParams),
  ...annotations('origin_relationships')
}
