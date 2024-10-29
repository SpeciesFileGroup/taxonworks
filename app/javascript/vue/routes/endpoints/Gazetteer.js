import baseCRUD from './base'
import AjaxCall from '@/helpers/ajaxCall.js'

const controller = 'gazetteers'
const permitParams = {
  gazetteer: {
    name: String,
    iso_3166_a2: String,
    iso_3166_a3: String,
    shapes: {
      geojson: [],
      wkt: [],
      points: [],
      ga_union: [],
      gz_union: []
    }
  },
  shapefile: {
    shp_doc_id: Number,
    shx_doc_id: Number,
    dbf_doc_id: Number,
    prj_doc_id: Number,
    cpg_doc_id: Number,
    name_field: String,
    iso_a2_field: String,
    iso_a3_field: String
  },
  projects: Array
}

export const Gazetteer = {
  ...baseCRUD(controller, permitParams),

  import: (params) => AjaxCall('post', `/${controller}/import.json`, params),

  preview: (params) => AjaxCall('post', `/${controller}/preview.json`, params),

  shapefile_fields: (params) => AjaxCall('get', `/${controller}/shapefile_fields.json`, { params })

}