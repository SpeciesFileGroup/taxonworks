import baseCRUD, { annotations } from './base'
import AjaxCall from 'helpers/ajaxCall'

const controller = 'otus'
const permitParams = {
  otu: {
    id: Number,
    name: String,
    taxon_name_id: Number
  }
}

export const Otu = {
  ...baseCRUD(controller, permitParams),
  ...annotations('otus'),

  breadcrumbs: (id) => AjaxCall('get', `/${controller}/${id}/breadcrumbs`),

  coordinate: (id) => AjaxCall('get', `/otus/${id}/coordinate`),

  navigation: (id) => AjaxCall('get', `/${controller}/${id}/navigation`),

  timeline: (id) => AjaxCall('get', `/${controller}/${id}/timeline`),

  filter: params => AjaxCall('get', `/${controller}.json`, params)
}
