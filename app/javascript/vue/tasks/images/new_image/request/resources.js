import ajaxCall from 'helpers/ajaxCall'

const GetLicenses = function () {
  return ajaxCall('get', '/attributions/licenses')
}

const GetCollectingEventSmartSelector = function () {
  return ajaxCall('get', '/collecting_events/select_options')
}

const GetCollectionObjectSmartSelector = function () {
  return ajaxCall('get', '/collection_objects/select_options')
}

const GetOtuSmartSelector = function () {
  return ajaxCall('get', '/otus/select_options?target=Depiction')
}

const GetPreparationTypes = function () {
  return ajaxCall('get', `/preparation_types.json`)
}

const GetOtu = function (id) {
  return ajaxCall('get', `/otus/${id}.json`)
}

const GetTaxonDeterminatorSmartSelector = function () {
  return ajaxCall('get', `/people/select_options?role_type=Determiner`)
}

const GetSqedMetadata = function () {
  return ajaxCall('get', '/sqed_depictions/metadata_options')
}

const GetSourceSmartSelector = function () {
  return ajaxCall('get', '/sources/select_options')
}

const CreateAttribution = function (data) {
  return ajaxCall('post', '/attributions.json', { attribution: data })
}

const CreateCitation = function (data) {
  return ajaxCall('post', '/citations.json', { citation: data })
}

const CreateDepiction = function (data) {
  return ajaxCall('post', '/depictions.json', { depiction: data })
}

const CreateCollectionObject = function (data) {
  return ajaxCall('post', '/collection_objects.json', { collection_object: data })
}

const CreateTaxonDetermination = function (data) {
  return ajaxCall('post', `/taxon_determinations.json`, { taxon_determination: data })
}

const UpdateAttribution = function (data) {
  return ajaxCall('patch', `/attributions/${data.id}.json`, { attribution: data })
}

const UpdateDepiction = function (data) {
  return ajaxCall('patch', `/depictions/${data.id}.json`, { depiction: data })
}

const DestroyImage = function (id) {
  return ajaxCall('delete', `/images/${id}.json`)
}

export {
  CreateAttribution,
  CreateCitation,
  CreateCollectionObject,
  CreateDepiction,
  GetLicenses,
  GetCollectingEventSmartSelector,
  GetCollectionObjectSmartSelector,
  GetTaxonDeterminatorSmartSelector,
  CreateTaxonDetermination,
  GetOtu,
  GetSourceSmartSelector,
  GetSqedMetadata,
  GetOtuSmartSelector,
  GetPreparationTypes,
  UpdateAttribution,
  UpdateDepiction,
  DestroyImage
}