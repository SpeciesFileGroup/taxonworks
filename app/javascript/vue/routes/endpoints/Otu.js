import baseCRUD, { annotations } from './base'
import AjaxCall from '@/helpers/ajaxCall'

const controller = 'otus'
const permitParams = {
  otu: {
    id: Number,
    name: String,
    taxon_name_id: Number
  }
}

export const Otu = {
  ...baseCRUD(controller, permitParams),
  ...annotations('otus'),

  breadcrumbs: (id) => AjaxCall('get', `/${controller}/${id}/breadcrumbs`),

  coordinate: (id) => AjaxCall('get', `/otus/${id}/coordinate`),

  distribution: (id) =>
    AjaxCall('get', `/otus/${id}/inventory/distribution.json`),

  // POST, not GET: a page of curator-refined match strings overruns the request URI.
  assignTaxonNameData: (params) =>
    AjaxCall('post', `/tasks/otus/assign_taxon_name/data.json`, params),

  duplicates: (params) =>
    AjaxCall('get', `/tasks/otus/duplicates/data`, { params }),

  geoJsonDistribution: (id) =>
    AjaxCall('get', `/otus/${id}/inventory/distribution.geojson`),

  navigation: (id) => AjaxCall('get', `/${controller}/${id}/navigation`),

  timeline: (id) => AjaxCall('get', `/${controller}/${id}/timeline.json`),

  citations: (id) => AjaxCall('get', `/${controller}/${id}/inventory/citations.json`),

  filter: (params) => AjaxCall('post', `/${controller}/filter.json`, params),

  batchUpdate: (params) =>
    AjaxCall('patch', `/${controller}/batch_update.json`, params),

  taxonomy: (otuId, params) =>
    AjaxCall('get', `/${controller}/${otuId}/inventory/taxonomy.json`, {
      params
    }),

  createMorphospeciesOtu: (params) =>
    AjaxCall('post', `/${controller}/create_morphospecies_otu.json`, params)
}
