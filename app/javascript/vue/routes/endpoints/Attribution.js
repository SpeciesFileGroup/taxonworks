import baseCRUD, { annotations } from './base'
import AjaxCall from 'helpers/ajaxCall'

const controller = 'attributions'
const permitParams = {
  attribution: {
    copyright_year: Number,
    license: String,
    attribution_object_type: String,
    attribution_object_id: Number,
    annotated_global_entity: String,
    _destroy: Boolean,
    roles_attributes: {
      id: Number,
      _destroy: Boolean,
      type: String,
      person_id: Number,
      organization_id: Number,
      position: Number,
      person_attributes: {
        last_name: String,
        first_name: String,
        suffix: String,
        prefix: String
      }
    }
  }
}

export const Attribution = {
  ...baseCRUD(controller, permitParams),
  ...annotations(controller),

  licenses: () => AjaxCall('get', `/${controller}/licenses`),

  roleTypes: () => AjaxCall('get', `/${controller}/role_types.json`)
}
