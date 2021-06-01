import baseCRUD from './base'
import AjaxCall from 'helpers/ajaxCall'

const permitParams = {
  depiction: {
    depiction_object_id: Number,
    depiction_object_type: String,
    annotated_global_entity: String,
    caption: String,
    is_metadata_depiction: Boolean,
    image_id: Number,
    figure_label: String,
    image_attributes: {
      image_file: String,
      tags_attributes: {
        id: Number,
        keyword_id: Number,
        _destroy: Boolean
      },
      identifiers_attributes: {
        id: Number,
        namespace_id: Number,
        identifier: String,
        type: String,
        _destroy: Boolean
      }
    },
    sqed_depiction_attributes: {
      id: Number,
      _destroy: Boolean,
      boundary_color: String,
      boundary_finder: String,
      has_border: Boolean,
      layout: String,
      metadata_map: []
    }
  }
}

export const Depiction = {
  ...baseCRUD('depictions', permitParams),

  sort: data => AjaxCall('patch', '/depictions/sort', data)
}
