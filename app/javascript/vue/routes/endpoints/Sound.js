import { ajaxCall } from '@/helpers'
import baseCRUD from './base'

const permitParams = {
  sound: {
    name: Number,
    sound_file: String
  }
}

export const Sound = {
  ...baseCRUD('sounds', permitParams),

  filter: (params) => ajaxCall('post', '/sounds/filter.json', params)
}
