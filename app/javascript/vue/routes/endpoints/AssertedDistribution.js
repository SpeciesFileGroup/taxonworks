import baseCRUD from './base'
import AjaxCall from '@/helpers/ajaxCall'

const controller = 'asserted_distributions'
const permitParams = {
  asserted_distribution: {
    id: Number,
    otu_id: String,
    asserted_distribution_shape_type: String,
    asserted_distribution_shape_id: Number,
    is_absent: Boolean,
    otu_attributes: {
      id: Number,
      _destroy: Boolean,
      name: String,
      taxon_name_id: Number
    },
    origin_citation_attributes: {
      id: Number,
      _destroy: Boolean,
      source_id: Number,
      pages: String
    },
    citations_attributes: {
      id: Number,
      is_original: Boolean,
      _destroy: Boolean,
      source_id: Number,
      pages: String,
      citation_object_id: Number,
      citation_object_type: String
    },
    data_attributes_attributes: {
      id: Number,
      _destroy: Boolean,
      controlled_vocabulary_term_id: Number,
      type: String,
      attribute_subject_id: Number,
      attribute_subject_type: String,
      value: Number
    }
  }
}

export const AssertedDistribution = {
  ...baseCRUD(controller, permitParams),

  filter: (params) => AjaxCall('post', `/${controller}/filter.json`, params),

  batchUpdate: (params) =>
    AjaxCall('patch', `/${controller}/batch_update.json`, params),

  batchTemplateCreate: (params) =>
    AjaxCall('post', `/${controller}/batch_template_create.json`, params),
}
