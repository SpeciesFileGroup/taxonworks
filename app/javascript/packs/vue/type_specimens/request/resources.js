import Vue from 'vue'; 
import VueResource from 'vue-resource';

Vue.use(VueResource);
Vue.http.headers.common['X-CSRF-Token'] = document.querySelector('meta[name="csrf-token"]').getAttribute('content');

const ajaxCall = function(type, url, data = null) {
  return new Promise(function(resolve, reject) {
    Vue.http[type](url, data).then(response => {
      return resolve(response.body);
    }, response => {
      handleError(response.body);
      return reject(response);
    })
  });
}

const handleError = function(json) {
  if (typeof json != 'object') return
  let errors = Object.keys(json);
  let errorMessage = '';

  errors.forEach(function(item) {
    errorMessage += json[item].join('<br>')
  });

  TW.workbench.alert.create(errorMessage, 'error');
}

const GetTypeMaterial = function(protonymId) {
  return ajaxCall('get', `/type_materials.json?protonym_id=${protonymId}`);
}

const GetPreparationTypes = function() {
  return ajaxCall('get', `/preparation_types.json`);
}

const GetTaxonName = function(id) {
  return ajaxCall('get', `/taxon_names/${id}.json`);
}

const CreateTypeMaterial = function(data) {
  return ajaxCall('post', `/type_materials.json`, data);
}

const UpdateTypeMaterial = function(id, data) {
  return ajaxCall('patch', `/type_materials/${id}.json`, data);
}

const DestroyTypeMaterial = function(id) {
  return ajaxCall('delete', `/type_materials/${id}.json`);
}

export {
  CreateTypeMaterial,
  GetTypeMaterial,
  GetTaxonName,
  GetPreparationTypes,
  UpdateTypeMaterial,
  DestroyTypeMaterial
}