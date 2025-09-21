import baseCRUD from './base'
import AjaxCall from '@/helpers/ajaxCall.js'

const controller = 'anatomical_parts'
const permitParams = {
  anatomical_part: {
    id: Number,
    name: Text,
    uri: Text,
    uri_label: Text,
    is_material: Boolean,
    global_id: String
  }
}

export const AnatomicalPart = {
  ...baseCRUD(controller, permitParams),

  filter: (params) => AjaxCall('post', `/${controller}/filter.json`, params)
}