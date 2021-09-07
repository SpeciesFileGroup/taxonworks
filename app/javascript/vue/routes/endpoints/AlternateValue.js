import baseCRUD from './base'

const controller = 'alternate_values'
const permitParams = {
  alternate_value: {
    value: String,
    type: String,
    language_id: Number,
    alternate_value_object_type: String,
    alternate_value_object_id: Number,
    alternate_value_object_attribute: String,
    is_community_annotation: Boolean,
    annotated_global_entity: String
  }
}

export const AlternateValue = {
  ...baseCRUD(controller, permitParams)
}
