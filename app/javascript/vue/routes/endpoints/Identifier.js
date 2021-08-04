import baseCRUD from './base'
import AjaxCall from 'helpers/ajaxCall'

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
  ...baseCRUD('identifiers', permitParams),

  types: () => AjaxCall('get', '/identifiers/identifier_types')
}
