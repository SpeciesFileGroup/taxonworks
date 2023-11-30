import baseCRUD, { annotations } from './base'
import AjaxCall from '@/helpers/ajaxCall'

const controller = 'collection_objects'
const permitParams = {
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
    notes_attributes: [],
    collecting_event_attributes: [],
    data_attributes_attributes: {
      id: Number,
      _destroy: Boolean,
      controlled_vocabulary_term_id: Number,
      type: String,
      value: String
    },
    taxon_determinations_attributes: {
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
    }
  }
}

export const CollectionObject = {
  ...baseCRUD(controller, permitParams),
  ...annotations(controller),

  dwc: (id, params = { rebuild: true }) =>
    AjaxCall('get', `/${controller}/${id}/dwc`, { params }),

  dwca: (id) => AjaxCall('get', `/${controller}/${id}/dwca`),

  dwcVerbose: (id, params = { rebuild: true }) =>
    AjaxCall('get', `/${controller}/${id}/dwc_verbose`, { params }),

  reportDwc: (params) =>
    AjaxCall('get', '/tasks/accessions/report/dwc.json', { params }),

  report: (params) => AjaxCall('get', `/${controller}/report.json`, { params }),

  dwcIndex: (params) => AjaxCall('get', `/${controller}/dwc_index`, { params }),

  filter: (params) => AjaxCall('post', `/${controller}/filter.json`, params),

  metadataBadge: (id) => AjaxCall('get', `/${controller}/${id}/metadata_badge`),

  navigation: (id) => AjaxCall('get', `/${controller}/${id}/navigation`),

  stepwiseDeterminations: (params) =>
    AjaxCall(
      'get',
      '/tasks/collection_objects/stepwise/determinations/data.json',
      { params }
    ),

  timeline: (id) => AjaxCall('get', `/${controller}/${id}/timeline`),

  sqedFilter: (params) =>
    AjaxCall(
      'get',
      '/tasks/accessions/breakdown/sqed_depiction/todo_map.json',
      { params }
    ),

  batchUpdate: (params) =>
    AjaxCall('post', `/${controller}/batch_update.json`, params),

  batchUpdateDwcOccurrence: (params) =>
    AjaxCall('post', `/${controller}/batch_update_dwc_occurrence`, params)
}
