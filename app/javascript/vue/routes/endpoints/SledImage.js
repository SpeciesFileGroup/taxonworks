import baseCRUD from './base'

const controller = 'sled_images'
const permitParams = {
  sled_image: {
    metadata: {
      index: Number,
      column: Object,
      metadata: Object,
      lowerCorner: [],
      upperCorner: [],
      object_layout: {}
    }
  },
  collection_object: {
    total: Number,
    preparation_type_id: Number,
    repository_id: Number,
    current_repository_id: Number,
    ranged_lot_category_id: Number,
    collecting_event_id: Number,
    buffered_collecting_event: String,
    buffered_determinations: String,
    buffered_other_labels: String,
    accessioned_at: String,
    deaccessioned_at: String,
    deaccession_reason: String,
    contained_in: String,
    collecting_event_attributes: [],
    data_attributes_attributes: {
      id: Number,
      _destroy: Boolean,
      controlled_vocabulary_term_id: Number,
      type: String,
      value: String
    },
    tags_attributes: {
      id: Number,
      _destroy: Boolean,
      keyword_id: Number
    },
    identifiers_attributes: {
      id: Number,
      _destroy: Boolean,
      identifier: String,
      namespace_id: Number,
      type: String,
      labels_attributes: {
        text: String,
        type: String,
        text_method: String,
        total: Number
      }
    }
  }
}

export const SledImage = {
  ...baseCRUD(controller, permitParams)
}
