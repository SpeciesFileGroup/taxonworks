import baseCRUD from './base'
import { ajaxCall } from '@/helpers'

const permitParams = {
  label: {
    text: String,
    total: Number,
    style: String,
    is_copy_edited: Boolean,
    is_printed: Boolean,
    type: String,
    label_object_id: Number,
    label_object_type: String,
    annotated_global_entity: String
  }
}

const controller = 'labels'
export const Label = {
  ...baseCRUD(controller, permitParams),

  batchCreate: (params) =>
    ajaxCall('post', `/${controller}/batch_create`, params)
}
