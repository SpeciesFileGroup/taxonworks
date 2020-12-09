import ajaxCall from 'helpers/ajaxCall'

const GetUserPreferences = () => ajaxCall('get', '/preferences.json')

const GetOtu = (id) => ajaxCall('get', `/otus/${id}.json`)

const GetOtusCoordinate = (id) => ajaxCall('get', `/otus/${id}/coordinate`)

const GetOtuAssertedDistribution = (data) => ajaxCall('get', '/asserted_distributions.json', { params: data })

const GetBiocurations = (id) => ajaxCall('get', `/biocuration_classifications.json?biological_collection_object_id=${id}`)

const GetDepictions = (model, id) => ajaxCall('get', `/${model}/${id}/depictions.json`)

const GetNotes = (id) => ajaxCall('get', `/otus/${id}/notes.json`)

const GetTags = (id) => ajaxCall('get', `/otus/${id}/tags.json`)

const GetCitations = (model, id) => ajaxCall('get', `/${model}/${id}/citations.json`)

const GetConfidences = (id) => ajaxCall('get', `/otus/${id}/confidences.json`)

const GetOtusCollectionObjects = (otusId) => ajaxCall('get', '/collection_objects.json', { params: { otu_ids: otusId, current_determinations: true } })

const GetGeoreferences = (ids) => ajaxCall('get', '/georeferences.json', { params: { collecting_event_ids: ids } })

const GetIdentifiers = (id) => ajaxCall('get', `/otus/${id}/identifiers.json`)

const GetDataAttributes = (id) => ajaxCall('get', `/otus/${id}/data_attributes.json`)

const GetContent = (id) => ajaxCall('get', `/contents.json?otu_id=${id}`, { params: { most_recent_updates: 100 } })

const GetTaxonDeterminations = (params) => ajaxCall('get', '/taxon_determinations.json', { params: params})

const GetTaxonDeterminationCitations = (id) => ajaxCall('get', `/taxon_determinations/${id}/citations.json`)

const GetTaxonNames = (params) => ajaxCall('get', '/taxon_names.json', { params: params })

const GetTaxonName = (id) => ajaxCall('get', `/taxon_names/${id}.json`)

const GetOtus = (id) => ajaxCall('get', `/taxon_names/${id}/otus.json`,
  {
    headers: {
      'Cache-Control': 'no-cache'
    }
  })

const GetBiologicalAssociations = (globalId) => ajaxCall('get', `/biological_associations.json?any_global_id=${globalId}`)

const GetNavigationOtu = (id) => ajaxCall('get', `/otus/${id}/navigation`)

const GetNomenclatureHistory = (id) => ajaxCall('get', `/otus/${id}/timeline.json`)

const GetCommonNames = (id) => ajaxCall('get', '/common_names.json', { params: { otu_id: id } })

const GetCollectingEvents = (ids) => ajaxCall('get', '/collecting_events.json', { params: { otu_ids: ids } })

const GetCollectionObjects = (params) => ajaxCall('get', '/collection_objects/dwc_index', { params: params })

const GetCollectionObject = (id) => ajaxCall('get', `/collection_objects/${id}.json`)

const GetRepository = (id) => ajaxCall('get', `/repositories/${id}.json`)

const GetBreadCrumbNavigation = (id) => ajaxCall('get', `/otus/${id}/breadcrumbs`)

const GetTypeMaterials = (id) => ajaxCall('get', `/type_materials.json?protonym_id=${id}`)

const UpdateUserPreferences = (id, data) => ajaxCall('patch', `/users/${id}.json`, { user: { layout: data } })

const GetSoftValidation = (globalId) => ajaxCall('get', '/soft_validations/validate', { params: { global_id: globalId } })

export {
  GetOtu,
  GetOtusCoordinate,
  GetUserPreferences,
  GetDepictions,
  GetContent,
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
  GetOtuAssertedDistribution,
  GetTaxonNames,
  GetTaxonName,
  GetTaxonDeterminations,
  GetTaxonDeterminationCitations,
  GetSoftValidation
}
