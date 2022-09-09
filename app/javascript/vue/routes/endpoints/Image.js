import baseCRUD, { annotations } from './base'
import AjaxCall from 'helpers/ajaxCall'

const controller = 'images'
const permitParams = {
  image: {
    image_file: String,
    rotate: Number,
    pixels_to_centimeter: Number,
    citations_attributes: {
      id: Number,
      is_original: Boolean,
      _destroy: Boolean,
      source_id: Number,
      pages: String,
      citation_object_id: Number,
      citation_object_type: String
    },
    sled_image_attributes: {
      id: Number,
      _destroy: Boolean,
      metadata: Object,
      object_layout: Object
    }
  }
}

export const Image = {
  ...baseCRUD(controller, permitParams),
  ...annotations(controller),

  filter: params => AjaxCall('post', `/${controller}/filter`, params)
}
