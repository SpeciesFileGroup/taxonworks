import baseCRUD from './base'
import AjaxCall from 'helpers/ajaxCall'

const permitParams = {
  container: {
    parent_id: Number,
    type: String,
    name: String,
    disposition: String,
    size_x: Number,
    size_y: Number,
    size_z: Number
  }
}

export const Container = {
  ...baseCRUD('containers', permitParams),

  for: (global_id) => AjaxCall('get', '/containers/for', { params: { global_id } })
}
