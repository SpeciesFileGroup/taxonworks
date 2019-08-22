import Vue from 'vue'
import VueResource from 'vue-resource'

Vue.use(VueResource)

const ajaxCall = function (type, url, data = null) {
  Vue.http.headers.common['X-CSRF-Token'] = document.querySelector('meta[name="csrf-token"]').getAttribute('content')
  return new Promise(function (resolve, reject) {
    Vue.http[type](url, data).then(response => {
      return resolve(response.body)
    }, response => {
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

const GetTypeMaterial = function (protonymId) {
  return ajaxCall('get', `/type_materials.json?protonym_id=${protonymId}`)
}

const GetBiocurationsTypes = function (protonymId) {
  return ajaxCall('get', `/controlled_vocabulary_terms.json?type[]=BiocurationClass`)
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

const CreateTypeMaterial = function (data) {
  return ajaxCall('post', `/type_materials.json`, data)
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
  CreateTypeMaterial,
  CreateBiocurationClassification,
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
  UpdateTypeMaterial,
  UpdateDepiction,
  DestroyTypeMaterial,
  DestroyBiocuration,
  DestroyCitation,
  UpdateCollectionObject,
  DestroyDepiction
}
