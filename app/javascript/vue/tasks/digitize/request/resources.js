import ajaxCall from 'helpers/ajaxCall'

const CreateOtu = function(id) {
  return ajaxCall('post', '/otus', { otu: { taxon_name_id: id } })
}

const GetOtus = function (id) {
  return ajaxCall('get', `/taxon_names/${id}/otus.json`, {
    headers: {
      'Cache-Control': 'no-cache'
    }
  })
}

const GetProjectPreferences = () => ajaxCall('get', '/project_preferences.json')

const GetUserPreferences = () => ajaxCall('get', '/preferences.json')

const GetSoftValidation = (globalId) => ajaxCall('get', '/soft_validations/validate', { params: { global_id: globalId } })

const CheckForExistingIdentifier = (namespaceId, identifier) => ajaxCall('get', `/identifiers.json?type=Identifier::Local::CatalogNumber&namespace_id=${namespaceId}&identifier=${identifier}`)

const GetIdentifiersFromCO = (id) => ajaxCall('get', `/identifiers.json?identifier_object_type=CollectionObject&identifier_object_id=${id}&type=Identifier::Local::CatalogNumber`)

const GetLabelsFromCE = (id) => ajaxCall('get', `/labels.json?label_object_id=${id}&label_object_type=CollectingEvent`)

const GetRecentCollectionObjects = () => ajaxCall('get', '/tasks/accessions/report/dwc.json?per=10')

const GetCEMd5Label = (label) => ajaxCall('get', '/collecting_events', { params: { md5_verbatim_label: true, in_labels: label } })

const UpdateUserPreferences = (id, data) => ajaxCall('patch', `/users/${id}.json`, { user: { layout: data } })

const FilterCollectingEvent = (params) => ajaxCall('get', '/collecting_events.json', { params: params })

const GetTaxonDeterminationCO = (id) => ajaxCall('get', `/taxon_determinations.json?biological_collection_object_ids[]=${id}`)

const GetTypeMaterialCO = (id) => ajaxCall('get', `/type_materials.json?collection_object_id=${id}`)

const GetOtu = (id) => ajaxCall('get', `/otus/${id}.json`)

const GetGeographicAreaByCoords = (lat,long) => ajaxCall('get', `/geographic_areas/by_lat_long?latitude=${lat}&longitude=${long}`)

const GetGeographicArea = (id) => ajaxCall('get', `/geographic_areas/${id}.json`, { params: { geo_json: true } })

const GetTypes = () => ajaxCall('get', '/type_materials/type_types.json')

const GetTaxon = (id) => ajaxCall('get', `/taxon_names/${id}.json`)

const GetCollectionEvent = (id) => ajaxCall('get', `/collecting_events/${id}.json`)

const CreateLabel = (data) => ajaxCall('post', '/labels', { label: data })

const UpdateLabel = (data) => ajaxCall('patch', `/labels/${data.id}.json`, { label: data })

const CreateIdentifier = (data) => ajaxCall('post', '/identifiers.json', { identifier: data })

const UpdateIdentifier = (data) => ajaxCall('patch', `/identifiers/${data.id}.json`, { identifier: data })

const UpdateCollectionEvent = (data) => ajaxCall('patch', `/collecting_events/${data.id}.json`, { collecting_event: data })

const GetContainer = (globalId) => ajaxCall('get', '/containers/for', { params: { global_id: globalId } })

const CreateContainer = (data) => ajaxCall('post', '/containers.json', { container: data })

const CreateContainerItem = (data) => ajaxCall('post', '/container_items.json', { container_item: data })

const CreateCollectionEvent = (data) => ajaxCall('post', '/collecting_events.json', { collecting_event: data })

const CloneCollectionEvent = (id) => ajaxCall('post', `/collecting_events/${id}/clone`)

const GetCollectionObject = (id) => ajaxCall('get', `/collection_objects/${id}.json`)

const GetCollectionObjects = (params) => ajaxCall('get', '/collection_objects.json', { params: params })

const CreateCollectionObject = (data) => ajaxCall('post', '/collection_objects.json', { collection_object: data })

const UpdateCollectionObject = (data) => ajaxCall('patch', `/collection_objects/${data.id}.json`, { collection_object: data })

const GetBiocurationsTypes = () => ajaxCall('get', '/controlled_vocabulary_terms.json?type[]=BiocurationClass')

const GetBiocurationsGroupTypes = () => ajaxCall('get', '/controlled_vocabulary_terms.json?type[]=BiocurationGroup')

const GetBiocurationsTags = (BiocurationGroupId) => ajaxCall('get', `/tags.json?keyword_id=${BiocurationGroupId}`)

const GetBiocurationsCreated = (biologicalId) => ajaxCall('get', `/biocuration_classifications.json?biological_collection_object_id=${biologicalId}`)

const GetPreparationTypes = () => ajaxCall('get', '/preparation_types.json')

const GetCollectionObjectDepictions = (id) => ajaxCall('get', `/collection_objects/${id}/depictions.json`)

const GetBiologicalRelationships = () => ajaxCall('get', '/biological_relationships.json')

const GetBiologicalRelationshipsCreated = (globalId) => ajaxCall('get', `/biological_associations.json?subject_global_id=${encodeURIComponent(globalId)}`)

const GetCollectionEventDepictions = (id) => ajaxCall('get', `/collecting_events/${id}/depictions.json`)

const GetRepository = (id) => ajaxCall('get', `/repositories/${id}.json`)

const GetIdentifier = (id) => ajaxCall('get', `/identifiers/${id}.json`)

const GetNamespace = (id) => ajaxCall('get', `/namespaces/${id}.json`)

const CreateBiologicalAssociation = (data) => ajaxCall('post', '/biological_associations.json', { biological_association: data })

const CreateTypeMaterial = (data) => ajaxCall('post', '/type_materials.json', { type_material: data })

const CreateTaxonDetermination = (data) => ajaxCall('post', '/taxon_determinations.json', { taxon_determination: data })

const ParseVerbatim = (label) => ajaxCall('get', '/collecting_events/parse_verbatim_label', { params: { verbatim_label: label } })

const CreateBiocurationClassification = (data) => ajaxCall('post', '/biocuration_classifications.json', data)

const UpdateTaxonDetermination = (data) => ajaxCall('patch', `/taxon_determinations/${data.id}.json`, { taxon_determination: data })

const UpdateTypeMaterial = (id, data) => ajaxCall('patch', `/type_materials/${id}.json`, { type_material: data })

const UpdateDepiction = (id, data) => ajaxCall('patch', `/depictions/${id}.json`, data)

const CreateDepiction = (data) => ajaxCall('post', '/depictions.json', { depiction: data })

const DestroyTaxonDetermination = (id) => ajaxCall('delete', `/taxon_determinations/${id}.json`)

const DestroyTypeMaterial = (id) => ajaxCall('delete', `/type_materials/${id}.json`)

const DestroyBiocuration = (id) => ajaxCall('delete', `/biocuration_classifications/${id}.json`)

const DestroyDepiction = (id) => ajaxCall('delete', `/depictions/${id}.json`)

const DestroyCollectionObject = (id) => ajaxCall('delete', `/collection_objects/${id}.json`)

const DestroyBiologicalAssociation = (id) => ajaxCall('delete', `/biological_associations/${id}.json`)

export {
  GetOtus,
  CreateOtu,
  GetProjectPreferences,
  GetCEMd5Label,
  GetSoftValidation,
  CheckForExistingIdentifier,
  CloneCollectionEvent,
  GetLabelsFromCE,
  GetUserPreferences,
  GetOtu,
  GetIdentifiersFromCO,
  GetRecentCollectionObjects,
  GetBiologicalRelationshipsCreated,
  GetBiologicalRelationships,
  GetGeographicAreaByCoords,
  FilterCollectingEvent,
  GetTaxonDeterminationCO,
  GetNamespace,
  GetIdentifier,
  GetTypeMaterialCO,
  GetTypes,
  GetTaxon,
  CreateTaxonDetermination,
  CreateBiologicalAssociation,
  CreateIdentifier,
  CreateLabel,
  UpdateLabel,
  UpdateIdentifier,
  GetCollectionObject,
  GetCollectionObjects,
  CreateCollectionObject,
  UpdateCollectionObject,
  UpdateTaxonDetermination,
  GetCollectionEvent,
  UpdateCollectionEvent,
  CreateCollectionEvent,
  GetBiocurationsTypes,
  GetBiocurationsCreated,
  GetBiocurationsGroupTypes,
  GetBiocurationsTags,
  GetPreparationTypes,
  GetCollectionObjectDepictions,
  GetCollectionEventDepictions,
  GetRepository,
  CreateTypeMaterial,
  CreateBiocurationClassification,
  UpdateTypeMaterial,
  UpdateDepiction,
  CreateDepiction,
  UpdateUserPreferences,
  DestroyTypeMaterial,
  DestroyBiocuration,
  DestroyDepiction,
  DestroyCollectionObject,
  DestroyTaxonDetermination,
  DestroyBiologicalAssociation,
  CreateContainer,
  CreateContainerItem,
  GetContainer,
  GetGeographicArea,
  ParseVerbatim
}
