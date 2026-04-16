import baseCRUD from './base'
import ajaxCall from '@/helpers/ajaxCall.js'

const controller = 'data_attributes'
const permitParams = {
  data_attribute: {
    annotated_global_entity: String,
    attribute_subject_id: Number,
    attribute_subject_type: String,
    controlled_vocabulary_term_id: Number,
    import_predicate: String,
    type: String,
    value: String
  }
}

export const DataAttribute = {
  ...baseCRUD(controller, permitParams),

  createBatch: (params) =>
    ajaxCall('post', `/${controller}/batch_create`, params),

  updateBatch: (params) =>
    ajaxCall('post', `/${controller}/batch_update_or_create`, params),

  brief: (params) => ajaxCall('post', `/${controller}/brief.json`, params),

  filter: (params) => ajaxCall('post', `/${controller}/filter.json`, params)
}
