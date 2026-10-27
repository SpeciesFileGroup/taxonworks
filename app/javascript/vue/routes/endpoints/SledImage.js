import baseCRUD from './base'
import AjaxCall from '@/helpers/ajaxCall'

const controller = 'sled_images'

// Mirrors `SledImagesController#sled_image_params`
const permitParams = {
  sled_image: {
    image_id: Number,
    step_identifier_on: String,
    horizontal_step_direction: String,
    vertical_step_direction: String,
    object_layout: {},
    metadata: {
      index: Number,
      row: Number,
      column: Number,
      metadata: String,
      lowerCorner: {
        x: Number,
        y: Number
      },
      upperCorner: {
        x: Number,
        y: Number
      }
    }
  },
  depiction: {
    is_metadata_depiction: Boolean
  },
  collection_object: {
    total: Number,
    collecting_event_id: Number,
    repository_id: Number,
    preparation_type_id: Number,
    identifiers_attributes: {
      namespace_id: Number,
      identifier: String,
      type: String
    },
    notes_attributes: {
      text: String
    },
    tags_attributes: {
      id: Number,
      _destroy: Boolean,
      keyword_id: Number
    },
    data_attributes_attributes: {
      id: Number,
      _destroy: Boolean,
      controlled_vocabulary_term_id: Number,
      type: String,
      value: String
    },
    taxon_determinations_attributes: {
      id: Number,
      _destroy: Boolean,
      otu_id: Number,
      year_made: Number,
      month_made: Number,
      day_made: Number,
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
      }
    }
  }
}

export const SledImage = {
  ...baseCRUD(controller, permitParams),

  nuke: (id) =>
    AjaxCall('delete', `/${controller}/${id}.json`, {
      params: { nuke: 'nuke' }
    })
}
