import baseCRUD from './base'
import AjaxCall from '@/helpers/ajaxCall'

const controller = 'biological_associations_graphs'
const permitParams = {
  biological_associations_graph: {
    name: String,
    layout: Object,
    origin_citation_attributes: {
      id: Number,
      _destroy: Boolean,
      source_id: Number,
      pages: Number
    },
    biological_associations_biological_associations_graphs_attributes: {
      id: Number,
      _destroy: Boolean,
      biological_association_id: Number
    }
  }
}

export const BiologicalAssociationGraph = {
  ...baseCRUD(controller, permitParams),

  filter: (params) => AjaxCall('post', `/${controller}/filter.json`, params)
}
