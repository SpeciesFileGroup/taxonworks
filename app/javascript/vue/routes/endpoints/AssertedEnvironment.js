import baseCRUD from './base'
import AjaxCall from '@/helpers/ajaxCall'

const permitParams = {
  asserted_environment: {
    id: Number,
    asserted_environment_object_id: Number,
    asserted_environment_object_type: String,
    uri: String,
    uri_label: String,
    position: Number,
    citations_attributes: {
      id: Number,
      is_original: Boolean,
      _destroy: Boolean,
      source_id: Number,
      pages: String,
      citation_object_id: Number,
      citation_object_type: String
    }
  }
}

const controller = 'asserted_environments'
export const AssertedEnvironment = {
  ...baseCRUD(controller, permitParams),

  filter: (params) => AjaxCall('post', `/${controller}/filter.json`, params),
  objectTypes: () => AjaxCall('get', `/${controller}/object_types.json`)
}
