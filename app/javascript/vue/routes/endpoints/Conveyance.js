import baseCRUD from './base'
import AjaxCall from '@/helpers/ajaxCall'

const permitParams = {
  conveyance: {
    sound_id: Number,
    conveyance_object_id: Number,
    conveyance_object_type: String,
    position: Number,
    start_time: Number,
    end_time: Number,
    sound_attributes: {
      name: String,
      sound_file: String
    }
  }
}

const controller = 'conveyances'
export const Conveyance = {
  ...baseCRUD('conveyances', permitParams),

  sort: (data) => AjaxCall('patch', `/${controller}/sort`, data),

  filter: (params) => AjaxCall('post', `/${controller}/filter`, params),

  navigation: (id) => AjaxCall('get', `/${controller}/${id}/navigation`),
}
