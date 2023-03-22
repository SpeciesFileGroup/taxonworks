import baseCRUD, { annotations } from './base'
import AjaxCall from 'helpers/ajaxCall'

const controller = 'descriptors'
const permitParams = {
  descriptor: {
    name: String,
    short_name: String,
    key_name: String,
    description_name: String,
    description: String,
    position: Number,
    type: String,
    gene_attribute_logic: String,
    default_unit: String,
    weight: String,
    character_states_attributes: {
      id: Number,
      descriptor_id: Number,
      _destroy: Boolean,
      label: String,
      name: String,
      position: Number,
      description_name: String,
      key_name: String
    },
    gene_attributes_attributes: {
      id: Number,
      _destroy: Boolean,
      sequence_id: Number,
      sequence_relationship_type: String,
      controlled_vocabulary_term_id: Number,
      position: Number
    }
  }
}

export const Descriptor = {
  ...baseCRUD(controller, permitParams),
  ...annotations(controller),

  units: () => AjaxCall('get', `/${controller}/units`),

  filter: params => AjaxCall('post', `/${controller}/filter.json`, params)
}
