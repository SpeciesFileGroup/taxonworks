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

  navigation: (id) => AjaxCall('get', `/${controller}/${id}/navigation`)
}
