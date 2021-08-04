import baseCRUD from './base'
import AjaxCall from 'helpers/ajaxCall'

const model = 'type_materials'
const permitParams = {
  type_material: {
    protonym_id: Number,
    collection_object_id: Number,
    type_type: String,
    roles_attributes: {
      id: Number,
      _destroy: Boolean,
      type: String,
      person_id: Number,
      position: Number,
      person_attributes: {
        last_name: String,
        first_name: String,
        suffix: String,
        prefix: String
      }
    },
    origin_citation_attributes: {
      id: Number,
      _destroy: Boolean,
      source_id: Number,
      pages: String
    },
    collection_object_attributes: {
      id: Number,
      buffered_collecting_event: String,
      buffered_other_labels: String,
      buffered_determinations: String,
      total: Number,
      collecting_event_id: Number,
      preparation_type_id: Number,
      repository_id: Number
    }
  }
}

export const TypeMaterial = {
  ...baseCRUD(model, permitParams),

  types: () => AjaxCall('get', `/${model}/type_types.json`)
}
