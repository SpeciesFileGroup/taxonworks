import baseCRUD from './base'
import AjaxCall from '@/helpers/ajaxCall.js'

const controller = 'anatomical_parts'
const permitParams = {
  anatomical_part: {
    id: Number,
    name: Text,
    uri: Text,
    uri_label: Text,
    is_material: Boolean,
    global_id: String,
    preparation_type_id: Number,
    inbound_origin_relationship_attributes: {
      old_object_id: Number,
      old_object_type: String
    }
  }
}

export const AnatomicalPart = {
  ...baseCRUD(controller, permitParams),

  filter: (params) => AjaxCall('post', `/${controller}/filter.json`, params),

  graph: (params) => AjaxCall('get', `/${controller}/graph.json`, { params }),

  ontologies: () => AjaxCall('get', `/${controller}/ontologies.json`),

  saveOntologyIdsToProject: (params) => AjaxCall('post', `/${controller}/select_ontologies/save_ontology_ids_to_project.json`, params),

  ontologyIdPreferences: (params) => AjaxCall('get', `/${controller}/select_ontologies/ontology_id_preferences.json`, { params }),

  childrenOf: (params) => AjaxCall('get', `/${controller}/children_of.json`, { params })
}