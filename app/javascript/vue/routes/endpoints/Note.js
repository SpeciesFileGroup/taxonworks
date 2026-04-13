import baseCRUD from './base'
import AjaxCall from '@/helpers/ajaxCall'

const controller = 'notes'
const permitParams = {
  note: {
    id: Number,
    text: String,
    note_object_id: Number,
    note_object_type: String,
    note_object_attribute: String,
    annotated_global_entity: String
  }
}

export const Note = {
  ...baseCRUD(controller, permitParams),

  filter: (params) => AjaxCall('post', `/${controller}/filter.json`, params)
}
