import ajaxCall from 'helpers/ajaxCall'

const CloneCollectionEvent = (id) => ajaxCall('post', `/collecting_events/${id}/clone`)

const CreateBiocurationClassification = (data) => ajaxCall('post', '/biocuration_classifications.json', data)

const CreateCollectingEvent = (ce) => ajaxCall('post', '/collecting_events.json', { collecting_event: ce })

const CreateCollectionObject = (co) => ajaxCall('post', '/collection_objects.json', { collection_object: co })

const CreateGeoreference = (data) => ajaxCall('post', '/georeferences.json', { georeference: data })

const CreateIdentifier = (identifier) => ajaxCall('post', '/identifiers.json', { identifier: identifier })

const CreateLabel = data => ajaxCall('post', '/labels.json', { label: data })

const CreateTaxonDetermination = (data) => ajaxCall('post', '/taxon_determinations.json', { taxon_determination: data })

const DestroyCollectingEvent = (id) => ajaxCall('delete', `/collecting_events/${id}`)

const DestroyDepiction = (id) => ajaxCall('delete', `/depictions/${id}`)

const GetBiocurationsGroupTypes = () => ajaxCall('get', '/controlled_vocabulary_terms.json?type[]=BiocurationGroup')

const GetBiocurationsTags = (BiocurationGroupId) => ajaxCall('get', `/tags.json?keyword_id=${BiocurationGroupId}`)

const GetBiocurationsTypes = () => ajaxCall('get', '/controlled_vocabulary_terms.json?type[]=BiocurationClass')

const GetCollectingEvent = (id) => ajaxCall('get', `/collecting_events/${id}.json`)

const GetCollectingEvents = (params) => ajaxCall('get', '/collecting_events.json', { params: params })

const GetCollectionObject = (id) => ajaxCall('get', `/collection_objects/${id}.json`)

const GetCollectionObjects = (params) => ajaxCall('get', '/collection_objects.json', { params })

const GetDepictions = (id) => ajaxCall('get', `/collecting_events/${id}/depictions.json`)

const GetGeographicArea = (id) => ajaxCall('get', `/geographic_areas/${id}.json`, { params: { geo_json: true }})

const GetGeographicAreaByCoords = (lat, long) => ajaxCall('get', '/geographic_areas/by_lat_long', { params: { latitude: lat, longitude: long, geo_json: true } })

const GetGeoreferences = (id) => ajaxCall('get', '/georeferences.json', { params: { collecting_event_id: id } })

const GetLabelsFromCE = (id) => ajaxCall('get', `/labels.json?label_object_id=${id}&label_object_type=CollectingEvent`)

const GetNamespace = (id) => ajaxCall('get', `/namespaces/${id}.json`)

const GetPreparationTypes = () => ajaxCall('get', '/preparation_types.json')

const GetProjectPreferences = () => ajaxCall('get', '/project_preferences.json')

const GetRecentCollectingEvents = () => ajaxCall('get', '/collecting_events.json', { params: { per: 10, recent: true } })

const GetSoftValidation = (globalId) => ajaxCall('get', '/soft_validations/validate', { params: { global_id: globalId } })

const GetTripCodeByCE = (ceId) => ajaxCall('get', `/identifiers.json?identifier_object_type=CollectingEvent&identifier_object_id=${ceId}&type=Identifier::Local::TripCode`)

const GetUserPreferences = () => ajaxCall('get', '/preferences.json')

const LoadSoftValidation = (globalId) => ajaxCall('get', '/soft_validations/validate', { params: { global_id: globalId } })

const NavigateCollectingEvents = (id) => ajaxCall('get', `/collecting_events/${id}/navigation`)

const ParseVerbatim = (label) => ajaxCall('get', '/collecting_events/parse_verbatim_label', { params: { verbatim_label: label } })

const RemoveIdentifier = (id) => ajaxCall('delete', `/identifiers/${id}.json`)

const UpdateCollectingEvent = (ce) => ajaxCall('patch', `/collecting_events/${ce.id}`, { collecting_event: ce })

const UpdateDepiction = (id, depiction) => ajaxCall('patch', `/depictions/${id}.json`, depiction)

const UpdateGeoreference = (data) => ajaxCall('patch', `/georeferences/${data.id}.json`, { georeference: data })

const UpdateIdentifier = (identifier) => ajaxCall('patch', `/identifiers/${identifier.id}.json`, { identifier: identifier })

const UpdateLabel = (data) => ajaxCall('patch', `/labels/${data.id}.json`, { label: data })

const UpdateUserPreferences = (id, data) => ajaxCall('patch', `/users/${id}.json`, { user: { layout: data } })

export {
  CloneCollectionEvent,
  CreateBiocurationClassification,
  CreateCollectingEvent,
  CreateCollectionObject,
  CreateGeoreference,
  CreateIdentifier,
  CreateLabel,
  CreateTaxonDetermination,
  DestroyCollectingEvent,
  DestroyDepiction,
  GetBiocurationsGroupTypes,
  GetBiocurationsTags,
  GetBiocurationsTypes,
  GetCollectingEvent,
  GetCollectingEvents,
  GetCollectionObject,
  GetCollectionObjects,
  GetDepictions,
  GetGeographicArea,
  GetGeographicAreaByCoords,
  GetGeoreferences,
  GetLabelsFromCE,
  GetNamespace,
  GetPreparationTypes,
  GetProjectPreferences,
  GetRecentCollectingEvents,
  GetSoftValidation,
  GetTripCodeByCE,
  GetUserPreferences,
  LoadSoftValidation,
  NavigateCollectingEvents,
  ParseVerbatim,
  RemoveIdentifier,
  UpdateCollectingEvent,
  UpdateDepiction,
  UpdateGeoreference,
  UpdateIdentifier,
  UpdateLabel,
  UpdateUserPreferences
}
