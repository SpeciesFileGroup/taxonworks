import baseCRUD from './base'
import AjaxCall from '@/helpers/ajaxCall'

const permitParams = {
  geographic_area: {
    name: String,
    level0_id: Number,
    level1_id: Number,
    level2_id: Number,
    parent_id: Number,
    geographic_area_type_id: Number,
    iso_3166_a2: String,
    iso_3166_a3: String,
    tdwgID: Number,
    data_origin: String
  }
}

export const GeographicArea = {
  ...baseCRUD('geographic_areas', permitParams),

  coordinates: (params) =>
    AjaxCall('get', '/geographic_areas/by_lat_long', { params })
}
