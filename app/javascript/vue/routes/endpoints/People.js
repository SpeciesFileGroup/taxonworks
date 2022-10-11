import baseCRUD, { annotations } from './base'
import AjaxCall from 'helpers/ajaxCall'

const controller = 'people'
const permitParams = {
  person: {
    type: String,
    no_namecase: String,
    last_name: String,
    first_name: String,
    suffix: String,
    prefix: String,
    year_born: Number,
    year_died: Number,
    year_active_start: Number,
    year_active_end: Number
  }
}

export const People = {
  ...baseCRUD(controller, permitParams),
  ...annotations(controller),

  roleTypes: () => AjaxCall('get', `/${controller}/role_types.json`),

  roles: id => AjaxCall('get', `/${controller}/${id}/roles.json`),

  filter: params => AjaxCall('post', `/${controller}/filter.json`, params),

  merge: (id, params) => AjaxCall('post', `/people/${id}/merge`, params)
}
