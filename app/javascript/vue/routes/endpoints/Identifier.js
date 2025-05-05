import baseCRUD from './base'
import AjaxCall from '@/helpers/ajaxCall'

const controller = 'identifiers'

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
  ...baseCRUD(controller, permitParams),

  types: () => AjaxCall('get', `/${controller}/identifier_types`),

  reorder: (params) => AjaxCall('patch', `/${controller}/reorder`, params)
}
