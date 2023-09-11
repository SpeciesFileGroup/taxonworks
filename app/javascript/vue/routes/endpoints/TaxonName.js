import baseCRUD from './base'
import AjaxCall from '@/helpers/ajaxCall'

const model = 'taxon_names'
const permitParams = {
  taxon_name: {
    id: Number,
    name: String,
    parent_id: Number,
    year_of_publication: Number,
    etymology: String,
    verbatim_author: String,
    verbatim_name: String,
    rank_class: String,
    type: String,
    masculine_name: String,
    feminine_name: String,
    neuter_name: String,
    also_create_otu: String,
    roles_attributes: {
      id: Number,
      _destroy: Boolean,
      type: String,
      person_id: Number,
      position: Number,
      person_attributes: {
        last_name: String,
        first_name: String,
        suffix: String,
        prefix: String
      }
    },
    origin_citation_attributes: {
      id: Number,
      _destroy: Boolean,
      source_id: Number,
      pages: Number
    },
    family_group_name_form_relationship_attributes: {
      id: Number,
      object_taxon_name_id: Number,
      _destroy: Boolean
    }
  }
}

export const TaxonName = {
  ...baseCRUD(model, permitParams),

  filter: (params) => AjaxCall('post', `/${model}/filter.json`, params),

  ranks: () => AjaxCall('get', `/${model}/ranks`),

  rankTable: (params) => AjaxCall('get', `/${model}/rank_table`, { params }),

  classifications: (id) =>
    AjaxCall('get', `/${model}/${id}/taxon_name_classifications`),

  relationships: (id, params) =>
    AjaxCall('get', `/${model}/${id}/taxon_name_relationships.json`, {
      params
    }),

  originalCombination: (id) =>
    AjaxCall('get', `/${model}/${id}/original_combination.json`),

  parse: (params) => AjaxCall('get', '/taxon_names/parse', { params }),

  predictedRank: (parentId, name) =>
    AjaxCall('get', `/${model}/predicted_rank`, {
      params: { parent_id: parentId, name }
    }),

  otus: (id) =>
    AjaxCall('get', `/${model}/${id}/otus.json`, {
      headers: { 'Cache-Control': 'no-cache' }
    })
}
