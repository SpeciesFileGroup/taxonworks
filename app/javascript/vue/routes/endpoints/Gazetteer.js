import baseCRUD from './base'
import AjaxCall from '@/helpers/ajaxCall.js'

const controller = 'gazetteers'
const permitParams = {
  gazetteer: {
    name: String,
    shapes: {
      geojson: [],
      wkt: [],
      points: []
    }
  },
  shapefile: {
    shp_doc_id: Number,
    shx_doc_id: Number,
    dbf_doc_id: Number,
    prj_doc_id: Number,
    name_field: String
  }
}

export const Gazetteer = {
  ...baseCRUD(controller, permitParams),

  import: (params) => AjaxCall('post', `/${controller}/import.json`, params)

}