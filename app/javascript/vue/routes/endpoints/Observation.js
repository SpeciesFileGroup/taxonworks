import baseCRUD, { annotations } from './base'
import ajaxCall from 'helpers/ajaxCall.js'

const controller = 'observations'
const permitParams = {
  observation: {
    character_state_id: Number,
    collection_object_id: Number,
    continuous_unit: String,
    continuous_value: String,
    description: String,
    descriptor_id: Number,
    frequency: Number,
    observation_object_id: Number,
    observation_object_type: String,
    observation_object_global_id: Number,
    otu_id: Number,
    presence: Boolean,
    sample_max: Number,
    sample_mean: String,
    sample_median: Number,
    sample_min: Number,
    sample_n: Number,
    sample_standard_deviation: String,
    sample_standard_error: String,
    sample_units: String,
    type: String,
    day_made: Number,
    month_made: Number,
    year_made: Number,
    time_made: String,
    images_attributes: {
      id: Number,
      _destroy: Boolean,
      image_file: String,
      rotate: Number
    },
    depictions_attributes: {
      id: Number,
      _destroy: Boolean,
      depiction_object_id: Number,
      depiction_object_type: String,
      annotated_global_entity: String,
      caption: String,
      is_metadata_depiction: Boolean,
      image_id: Number,
      figure_label: String,
      image_attributes: {
        image_file: String
      }
    }
  }
}

export const Observation = {
  ...baseCRUD(controller, permitParams),
  ...annotations(controller),

  codeRow: params => ajaxCall('post', `/${controller}/code_column`, params),

  destroyColumn: params => ajaxCall('delete', '/observations/destroy_column.json', { params }),

  destroyRow: params => ajaxCall('delete', '/observations/destroy_row.json', { params })
}
