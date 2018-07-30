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

const GetTypes = function () {
  return ajaxCall('get', `/type_materials/type_types.json`)
}

const GetTaxon = function (id) {
  return ajaxCall('get', `/taxon_names/${id}.json`)
}

const GetCollectionEvent = function (id) {
  return ajaxCall('get', `/collecting_events/${id}.json`)
}
const CreateIdentifier = function (data) {
  return ajaxCall('post', `/identifiers.json`, { identifier: data })
}

const UpdateIdentifier = function (data) {
  return ajaxCall('patch', `/identifiers/${data.id}.json`, { identifier: data })
} 

const UpdateCollectionEvent = function (id, data) {
  return ajaxCall('patch', `/collecting_events/${id}.json`, { collecting_event: data })
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

const GetDepictions = function (id) {
  return ajaxCall('get', `/collection_objects/${id}/depictions.json`)
}

const GetRepository = function (id) {
  return ajaxCall('get', `/repositories/${id}.json`)
}

const CreateTypeMaterial = function (data) {
  return ajaxCall('post', `/type_materials.json`, { type_material: data })
}

const CreateBiocurationClassification = function (data) {
  return ajaxCall('post', `/biocuration_classifications.json`, data)
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

export {
  GetTypes,
  GetTaxon,
  CreateIdentifier,
  UpdateIdentifier,
  GetCollectionObject,
  CreateCollectionObject,
  UpdateCollectionObject,
  GetCollectionEvent,
  UpdateCollectionEvent,
  CreateCollectionEvent,
  GetBiocurationsTypes,
  GetBiocurationsCreated,
  GetBiocuration,
  GetBiocurationsGroupTypes,
  GetBiocurationsTags,
  GetPreparationTypes,
  GetDepictions,
  GetRepository,
  CreateTypeMaterial,
  CreateBiocurationClassification,
  UpdateTypeMaterial,
  UpdateDepiction,
  DestroyTypeMaterial,
  DestroyBiocuration,
  DestroyDepiction
}