import baseCRUD from './base'
import AjaxCall from '@/helpers/ajaxCall'

const controller = 'compositions'
const permitParams = {
  composition: {
    name: String,
    description: String,
    type: String
  }
}

export const Composition = {
  ...baseCRUD(controller, permitParams),

  selectOptions: (params) =>
    AjaxCall('get', `/${controller}/select_options`, { params }),

  compositionItems: (id, params) =>
    AjaxCall('get', `/${controller}/${id}/composition_items.json`, { params })
}
