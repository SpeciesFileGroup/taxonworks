import baseCRUD from './base'
import AjaxCall from '@/helpers/ajaxCall'

const controller = 'field_occurrences'

const permitParams = {
  field_occurrence: {
    total: Number,
    is_absent: Boolean,
    ranged_lot_category_id: Number,
    collecting_event_id: Number,
    taxon_determination_id: Number,
    collecting_event_attributes: [],
    data_attributes_attributes: {
      id: Number,
      _destroy: Boolean,
      controlled_vocabulary_term_id: Number,
      type: String,
      value: String
    },

    taxon_determinations_attributes: {
      id: Number,
      otu_id: Number,
      year_made: Number,
      month_made: Number,
      day_made: Number,
      position: Number,
      roles_attributes: [],
      otu_attributes: {
        id: Number,
        _destroy: Boolean,
        name: String,
        taxon_name_id: Number
      }
    },

    depictions_attributes: {
      id: Number,
      _destroy: Boolean,
      svg_clip: String,
      svg_view_box: String,
      position: Number,
      caption: String,
      figure_label: String,
      image_id: Number
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
    },

    biocuration_classifications_attributes: {
      id: Number,
      _destroy: Boolean,
      biocuration_class_id: Number
    }
  }
}

export const FieldOccurrence = {
  ...baseCRUD(controller, permitParams),

  filter: (params) => AjaxCall('post', `/${controller}/filter.json`, params)
}
