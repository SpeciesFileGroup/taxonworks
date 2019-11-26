import ajaxCall from 'helpers/ajaxCall'

const GetOtu = function (id) {
  return ajaxCall('get', `/otus/${id}.json`)
}

const GetDepictions = function (id) {
  return ajaxCall('get', `/otus/${id}/depictions.json`)
}

const GetNotes = function (id) {
  return ajaxCall('get', `/otus/${id}/notes.json`)
}

const GetTags = function (id) {
  return ajaxCall('get', `/otus/${id}/tags.json`)
}

const GetCitations = function (id) {
  return ajaxCall('get', `/otus/${id}/citations.json`)
}

const GetConfidences = function (id) {
  return ajaxCall('get', `/otus/${id}/confidences.json`)
}

const GetIdentifiers = function (id) {
  return ajaxCall('get', `/otus/${id}/identifiers.json`)
}

const GetDataAttributes = function (id) {
  return ajaxCall('get', `/otus/${id}/data_attributes.json`)
}

const GetContent = function (id) {
  return ajaxCall('get', `/contents/filter.json?otu_id=${id}`, { params: { most_recent_updates: 100 } })
}

const GetAssertedDistributions = function (id) {
  return ajaxCall('get', `/asserted_distributions?otu_id=${id}`)
}

const GetBiologicalAssociations = function (globalId) {
  return ajaxCall('get', `/biological_associations?any_global_id=${globalId}`)
}

const GetNomenclatureHistory = function (id) {
  return ajaxCall('get', `/taxon_names/${id}/catalog`)
}

const GetCollectingEvents = function(ids) {
  return ajaxCall('get', '/collecting_events.json', { params: { otu_ids: ids } })
}

const GetCollectionObjects = function(ids) {
  return ajaxCall('get', '/collection_objects/dwc_index', { params: { otu_ids: ids, current_determinations: true } })
}

const GetBreadCrumbNavigation = (id) => {
  return ajaxCall('get', `/otus/${id}/breadcrumbs`)
}

export {
  GetOtu,
  GetDepictions,
  GetContent,
  GetAssertedDistributions,
  GetBiologicalAssociations,
  GetNotes,
  GetTags,
  GetCitations,
  GetDataAttributes,
  GetConfidences,
  GetIdentifiers,
  GetNomenclatureHistory,
  GetCollectingEvents,
  GetCollectionObjects,
  GetBreadCrumbNavigation
}