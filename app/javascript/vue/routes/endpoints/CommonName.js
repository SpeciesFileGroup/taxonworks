import baseCRUD from './base'
import AjaxCall from '@/helpers/ajaxCall'

const controller = 'common_names'
const permitParams = {
  common_name: {
    name: String,
    geographic_area_id: Number,
    otu_id: Number,
    language_id: Number,
    start_year: Number,
    end_year: Number
  }
}

export const CommonName = {
  ...baseCRUD(controller, permitParams),

  filter: (params) => AjaxCall('post', `/${controller}/filter.json`, params)
}
