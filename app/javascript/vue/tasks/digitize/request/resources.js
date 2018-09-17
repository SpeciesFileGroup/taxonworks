import Vue from 'vue'
import VueResource from 'vue-resource'

Vue.use(VueResource)
Vue.http.headers.common['X-CSRF-Token'] = document.querySelector('meta[name="csrf-token"]').getAttribute('content')

const ajaxCall = function (type, url, data = null) {
  return new Promise(function (resolve, reject) {
    Vue.http[type](url, data).then(response => {
      console.log(response)
      return resolve(response.body)
    }, response => {
      console.log(response)
      handleError(response.body)
      return reject(response)
    })
  })
}

const handleError = function (json) {
  if (typeof json !== 'object') return
  let errors = Object.keys(json)
  let errorMessage = ''

  errors.forEach(function (item) {
    errorMessage += json[item].join('<br>')
  })

  TW.workbench.alert.create(errorMessage, 'error')
}

const GetUserPreferences = function () {
  return ajaxCall('get', `/preferences.json`)
}

const UpdateUserPreferences = function (id, data) {
  return ajaxCall('patch', `/users/${id}.json`, { user: { layout: data } })
}

const GetRepositorySmartSelector = function () {
  return ajaxCall('get', `/repositories/select_options`)
}

const GetCollectorsSmartSelector = function () {
  return ajaxCall('get', `/people/select_options?role=Collector`)
}

const GetGeographicSmartSelector = function () {
  return ajaxCall('get', `/geographic_areas/select_options`)
}

const GetTaxonDeterminationCO = function (id) {
  return ajaxCall('get', `/taxon_determinations.json?biological_collection_object_ids[]=${id}`)
}

const GetTypeMaterialCO = function (id) {
  return ajaxCall('get', `/type_materials.json?biological_collection_object_ids[]=${id}`)
}

const GetOtu = function (id) {
  return ajaxCall('get', `/otus/${id}.json`)
}

const GetTypes = function () {
  return ajaxCall('get', `/type_materials/type_types.json`)
}

const GetTaxon = function (id) {
  return ajaxCall('get', `/taxon_names/${id}.json`)
}

const GetCollectionEvent = function (id) {
  return ajaxCall('get', `/collecting_events/${id}.json`)
}

const CreateLabel = function (data) {
  return ajaxCall('post', '/labels', { label: data })
}

const UpdateLabel = function (data) {
  return ajaxCall('patch', `/labels/${data.id}.json`, { label: data })
} 

const CreateIdentifier = function (data) {
  return ajaxCall('post', `/identifiers.json`, { identifier: data })
}

const UpdateIdentifier = function (data) {
  return ajaxCall('patch', `/identifiers/${data.id}.json`, { identifier: data })
} 

const UpdateCollectionEvent = function (data) {
  return ajaxCall('patch', `/collecting_events/${data.id}.json`, { collecting_event: data })
}

const CreateContainer = function (data) {
  return ajaxCall('post', `/containers.json`, { container: data })
}

const CreateContainerItem = function (data) {
  return ajaxCall('post', `/container_items.json`, { container_item: data })
}

const CreateCollectionEvent = function (data) {
  return ajaxCall('post', `/collecting_events.json`, { collecting_event: data })
}

const GetCollectionObject = function (id) {
  return ajaxCall('get', `/collection_objects/${id}.json`)
}

const CreateCollectionObject = function (data) {
  return ajaxCall('post', `/collection_objects.json`, { collection_object: data })
}

const UpdateCollectionObject = function (data) {
  return ajaxCall('patch', `/collection_objects/${data.id}.json`, { collection_object: data })
}

const GetBiocurationsTypes = function (protonymId) {
  return ajaxCall('get', `/controlled_vocabulary_terms.json?of_type[]=BiocurationClass`)
}

const GetBiocurationsGroupTypes = function (protonymId) {
  return ajaxCall('get', `/controlled_vocabulary_terms.json?of_type[]=BiocurationGroup`)
}

const GetBiocurationsTags = function (BiocurationGroupId) {
  return ajaxCall('get', `/tags.json?keyword_id=${BiocurationGroupId}`)
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

const GetCollectionObjectDepictions = function (id) {
  return ajaxCall('get', `/collection_objects/${id}/depictions.json`)
}

const GetCollectionEventDepictions = function (id) {
  return ajaxCall('get', `/collecting_events/${id}/depictions.json`)
}

const GetRepository = function (id) {
  return ajaxCall('get', `/repositories/${id}.json`)
}

const CreateTypeMaterial = function (data) {
  return ajaxCall('post', `/type_materials.json`, { type_material: data })
}

const CreateTaxonDetermination = function (data) {
  return ajaxCall('post', `/taxon_determinations.json`, { taxon_determination: data })
}

const CreateBiocurationClassification = function (data) {
  return ajaxCall('post', `/biocuration_classifications.json`, data)
}

const UpdateTaxonDetermination = function (data) {
  return ajaxCall('patch', `/taxon_determinations.json`, { taxon_determination: data })
}

const UpdateTypeMaterial = function (id, data) {
  return ajaxCall('patch', `/type_materials/${id}.json`, { type_material: data })
}

const UpdateDepiction = function (id, data) {
  return ajaxCall('patch', `/depictions/${id}.json`, data)
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

const DestroyCollectionObject = function (id) {
  return ajaxCall('delete', `/collection_objects/${id}.json`)
}

export {
  GetUserPreferences,
  GetOtu,
  GetCollectorsSmartSelector,
  GetRepositorySmartSelector,
  GetGeographicSmartSelector,
  GetTaxonDeterminationCO,
  GetTypeMaterialCO,
  GetTypes,
  GetTaxon,
  CreateTaxonDetermination,
  CreateIdentifier,
  CreateLabel,
  UpdateLabel,
  UpdateIdentifier,
  GetCollectionObject,
  CreateCollectionObject,
  UpdateCollectionObject,
  UpdateTaxonDetermination,
  GetCollectionEvent,
  UpdateCollectionEvent,
  CreateCollectionEvent,
  GetBiocurationsTypes,
  GetBiocurationsCreated,
  GetBiocuration,
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
  UpdateUserPreferences,
  DestroyTypeMaterial,
  DestroyBiocuration,
  DestroyDepiction,
  DestroyCollectionObject,
  CreateContainer,
  CreateContainerItem
}