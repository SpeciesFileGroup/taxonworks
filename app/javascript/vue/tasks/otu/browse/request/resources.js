import ajaxCall from 'helpers/ajaxCall'

const GetUserPreferences = () => {
  return ajaxCall('get', '/preferences.json')
}

const GetOtu = function (id) {
  return ajaxCall('get', `/otus/${id}.json`)
}

const GetOtuAssertedDistribution = (data) => {
  return ajaxCall('get', `/asserted_distributions.json`, { params: data })
}


const GetBiocurations = (id) => {
  return ajaxCall('get', `/biocuration_classifications.json?biological_collection_object_id=${id}`)
}

const GetDepictions = function (model, id) {
  return ajaxCall('get', `/${model}/${id}/depictions.json`)
}

const GetNotes = function (id) {
  return ajaxCall('get', `/otus/${id}/notes.json`)
}

const GetTags = function (id) {
  return ajaxCall('get', `/otus/${id}/tags.json`)
}

const GetCitations = function (model, id) {
  return ajaxCall('get', `/${model}/${id}/citations.json`)
}

const GetConfidences = function (id) {
  return ajaxCall('get', `/otus/${id}/confidences.json`)
}

const GetOtusCollectionObjects = function (otuId) {
  return ajaxCall('get', '/collection_objects.json', { params: { otu_ids: [otuId], current_determinations: true } })
}

const GetGeoreferences = function (ids) {
  return ajaxCall('get', '/georeferences.json', { params: { collecting_event_ids: ids } })
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

const GetOtus = function (id) {
  return ajaxCall('get', `/taxon_names/${id}/otus.json`, {
    headers: {
      'Cache-Control': 'no-cache'
    }
  })
}

const GetAssertedDistributions = function (id) {
  return ajaxCall('get', `/asserted_distributions.json?otu_id=${id}`)
}

const GetBiologicalAssociations = function (globalId) {
  return ajaxCall('get', `/biological_associations.json?any_global_id=${globalId}`)
}

const GetNavigationOtu = (id) => {
  return ajaxCall('get', `/otus/${id}/navigation`)
}

const GetNomenclatureHistory = function (id) {
  return ajaxCall('get', `/otus/${id}/timeline.json`)
}

const GetCommonNames = function(id) {
  return ajaxCall('get', '/common_names.json', { params: { otu_id: id } })
}

const GetCollectingEvents = function(ids) {
  return ajaxCall('get', '/collecting_events.json', { params: { otu_ids: ids } })
}

const GetCollectionObjects = function(params) {
  return ajaxCall('get', '/collection_objects/dwc_index', { params: params })
}

const GetCollectionObject = function(id) {
  return ajaxCall('get', `/collection_objects/${id}.json`)
}

const GetRepository = function(id) {
  return ajaxCall('get', `/repositories/${id}.json`)
}

const GetBreadCrumbNavigation = (id) => {
  return ajaxCall('get', `/otus/${id}/breadcrumbs`)
}

const GetTypeMaterials = (id) => {
  return ajaxCall('get', `/type_materials.json?protonym_id=${id}`)
}

const UpdateUserPreferences = (id, data) => {
  return ajaxCall('patch', `/users/${id}.json`, { user: { layout: data } })
}

export {
  GetOtu,
  GetUserPreferences,
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
  GetNavigationOtu,
  GetCollectingEvents,
  GetCollectionObject,
  GetCollectionObjects,
  GetBreadCrumbNavigation,
  GetBiocurations,
  GetRepository,
  GetTypeMaterials,
  GetCommonNames,
  GetOtus,
  GetGeoreferences,
  GetOtusCollectionObjects,
  UpdateUserPreferences,
  GetOtuAssertedDistribution
}
