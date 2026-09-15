import baseCRUD from './base'
import AjaxCall from '@/helpers/ajaxCall'

const controller = 'asserted_environments'
const permitParams = {
  asserted_environment: {
    id: Number,
    asserted_environment_object_id: Number,
    asserted_environment_object_type: String,
    uri: String,
    uri_label: String,
    position: Number
  }
}

export const AssertedEnvironment = {
  ...baseCRUD(controller, permitParams),

  filter: (params) => AjaxCall('post', `/${controller}/filter.json`, params),
  objectTypes: () => AjaxCall('get', `/${controller}/object_types.json`)
}
