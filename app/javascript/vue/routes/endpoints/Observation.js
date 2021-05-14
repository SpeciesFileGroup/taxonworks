import baseCRUD, { annotations } from './base'

const controller = 'observations'
const permitParams = {
  observation: {
    observation_object_global_id: Number,
    descriptor_id: Number,
    otu_id: Number,
    collection_object_id: Number,
    character_state_id: Number,
    frequency: Number,
    continuous_value: String,
    continuous_unit: String,
    sample_n: Number,
    sample_min: Number,
    sample_max: Number,
    sample_median: Number,
    sample_mean: String,
    sample_units: String,
    sample_standard_deviation: String,
    sample_standard_error: String,
    presence: Boolean,
    description: String,
    type: String,
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
  ...annotations(controller)
}
