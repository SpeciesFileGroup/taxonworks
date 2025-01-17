import baseCRUD from './base'
import AjaxCall from '@/helpers/ajaxCall'

const permitParams = {
  conveyance: {
    sound_id: Number,
    conveyance_object_id: Number,
    conveyance_object_type: String,
    position: Number,
    sound_attributes: {
      name: String,
      sound_file: String
    }
  }
}

export const Conveyance = {
  ...baseCRUD('conveyances', permitParams),

  sort: (data) => AjaxCall('patch', '/conveyances/sort', data),

  filter: (params) => AjaxCall('post', '/conveyances/filter', params)
}
