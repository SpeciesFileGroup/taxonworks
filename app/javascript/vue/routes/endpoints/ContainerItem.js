import baseCRUD from './base'
import AjaxCall from '@/helpers/ajaxCall'

const permitParams = {
  container_item: {
    global_entity: String,
    contained_object_id: Number,
    contained_object_type: String,
    container_id: Number,
    parent_id: Number,
    disposition: String,
    disposition_x: Number,
    disposition_y: Number,
    disposition_z: Number
  }
}

export const ContainerItem = {
  ...baseCRUD('container_items', permitParams),

  batchAdd: (params) => AjaxCall('post', '/container_items/batch_add', params)
}
