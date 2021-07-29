import baseCRUD from './base'
import AjaxCall from 'helpers/ajaxCall'

const controller = 'tags'
const permitParams = {
  tag: {
    keyword_id: Number,
    tag_object_id: Number,
    tag_object_type: String,
    tag_object_attribute: String,
    annotated_global_entity: String,
    _destroy: Boolean,
    keyword_attributes: {
      name: String,
      definition: String,
      uri: String,
      uri_relation: String,
      css_color: String
    }
  }
}

export const Tag = {
  ...baseCRUD(controller, permitParams),

  createBatch: (params) => AjaxCall('post', `/${controller}/batch_create`, params),

  exists: (params) => AjaxCall('get', `/${controller}/exists`, { params })
}
