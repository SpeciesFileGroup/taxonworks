import baseCRUD from './base'
import AjaxCall from 'helpers/ajaxCall'

const controller = 'collection_objects'
const permitParams = {
  confidence: {
    annotated_global_entity: String,
    confidence_level_id: Number,
    confidence_object_id: Number,
    confidence_object_type: String,
    confidence_level_attributes: {
      id: Number,
      _destroy: Boolean,
      name: String,
      definition: String,
      uri: String,
      uri_relation: String,
    }
  }
}

export const Confidence = {
  ...baseCRUD('confidences', permitParams),

  exists: (params) => AjaxCall('get', `/${controller}/exists`, { params })
}
