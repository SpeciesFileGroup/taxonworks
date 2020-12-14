import ajaxCall from 'helpers/ajaxCall'

const GetTypeMaterial = function (protonymId) {
  return ajaxCall('get', `/type_materials.json?protonym_id=${protonymId}`)
}

const GetBiocurationsTypes = function (protonymId) {
  return ajaxCall('get', `/controlled_vocabulary_terms.json?type[]=BiocurationClass`)
}

const CheckForExistingIdentifier = function (namespaceId, identifier) {
  return ajaxCall('get', `/identifiers.json?type=Identifier::Local::CatalogNumber&namespace_id=${namespaceId}&identifier=${identifier}`)
}

const GetBiocurationsCreated = function (biologicalId) {
  return ajaxCall('get', `/biocuration_classifications.json?biological_collection_object_id=${biologicalId}`)
}

const GetBiocuration = function (biologicalId, biocurationClassId) {
  return ajaxCall('get', `/biocuration_classifications.json?biocuration_class_id=${biocurationClassId}&biological_collection_object_id=${biologicalId}`)
}

const GetPreparationTypes = function () {
  return ajaxCall('get', `/preparation_types.json`)
}

const GetTypes = function () {
  return ajaxCall('get', `/type_materials/type_types.json`)
}

const GetSource = function (id) {
  return ajaxCall('get', `/sources/${id}.json`)
}

const GetDepictions = function (id) {
  return ajaxCall('get', `/collection_objects/${id}/depictions.json`)
}

const GetTaxonName = function (id) {
  return ajaxCall('get', `/taxon_names/${id}.json`)
}

const GetCollectionEvent = function (id) {
  return ajaxCall('get', `/collecting_events/${id}.json`)
}

const GetRepository = function (id) {
  return ajaxCall('get', `/repositories/${id}.json`)
}

const GetIdentifiersFromCO = function (id) {
  return ajaxCall('get', `/identifiers.json?identifier_object_type=CollectionObject&identifier_object_id=${id}&type=Identifier::Local::CatalogNumber`)
}

const GetNamespace = function (id) {
  return ajaxCall('get', `/namespaces/${id}.json`)
}

const LoadSoftvalidation = function (global_id) {
  return ajaxCall('get', `/soft_validations/validate?global_id=${global_id}`)
}

const CreateTypeMaterial = function (data) {
  return ajaxCall('post', `/type_materials.json`, data)
}

const CreateIdentifier = function (data) {
  return ajaxCall('post', '/identifiers.json', { identifier: data })
}

const CreateBiocurationClassification = function (data) {
  return ajaxCall('post', `/biocuration_classifications.json`, data)
}

const UpdateTypeMaterial = function (id, data) {
  return ajaxCall('patch', `/type_materials/${id}.json`, data)
}

const UpdateDepiction = function (id, data) {
  return ajaxCall('patch', `/depictions/${id}.json`, data)
}

const UpdateCollectionObject = function (id, data) {
  return ajaxCall('patch', `/collection_objects/${id}.json`, { collection_object: data })
}

const UpdateIdentifier = function (data) {
  return ajaxCall('patch', `/identifiers/${data.id}.json`, { identifier: data })
}

const DestroyCitation = function (id) {
  return ajaxCall('delete', `/citations/${id}.json`)
}

const DestroyTypeMaterial = function (id) {
  return ajaxCall('delete', `/type_materials/${id}.json`)
}

const DestroyBiocuration = function (id) {
  return ajaxCall('delete', `/biocuration_classifications/${id}.json`)
}

const DestroyDepiction = function (id) {
  return ajaxCall('delete', `/depictions/${id}.json`)
}

export {
  CheckForExistingIdentifier,
  CreateTypeMaterial,
  CreateBiocurationClassification,
  CreateIdentifier,
  GetBiocurationsCreated,
  GetTypeMaterial,
  GetTaxonName,
  GetTypes,
  GetSource,
  GetDepictions,
  GetPreparationTypes,
  GetRepository,
  GetBiocuration,
  GetBiocurationsTypes,
  GetCollectionEvent,
  GetIdentifiersFromCO,
  GetNamespace,
  UpdateTypeMaterial,
  UpdateDepiction,
  UpdateIdentifier,
  DestroyTypeMaterial,
  DestroyBiocuration,
  DestroyCitation,
  UpdateCollectionObject,
  DestroyDepiction,
  LoadSoftvalidation
}
