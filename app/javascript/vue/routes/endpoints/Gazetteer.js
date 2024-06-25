import baseCRUD from './base'
import AjaxCall from '@/helpers/ajaxCall.js'

const controller = 'gazetteers'
const permitParams = {
  gazetteer: {
    name: String,
    shapes: {
      geojson: [],
      wkt: []
    }
    //geographic_item_attributes: { shape: Object }
  }
}

export const Gazetteer = {
  ...baseCRUD(controller, permitParams)
}