import { ajaxCall } from '@/helpers'
import baseCRUD from './base'

const controller = 'protocol_relationships'
const permitParams = {
  protocol_relationship: {
    protocol_id: Number,
    protocol_relationship_object_id: Number,
    protocol_relationship_object_type: String,
    annotated_global_entity: String
  }
}

export const ProtocolRelationship = {
  ...baseCRUD(controller, permitParams),

  batchByFilter: (params) =>
    ajaxCall('post', `/${controller}/batch_by_filter_scope`, params)
}
