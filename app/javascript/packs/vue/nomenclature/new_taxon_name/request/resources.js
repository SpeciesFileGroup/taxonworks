import Vue from 'vue'; 
import VueResource from 'vue-resource';

Vue.use(VueResource);

var token = $('[name="csrf-token"]').attr('content');
Vue.http.headers.common['X-CSRF-Token'] = token;

const saveNewTaxonStatus = function(newClassification) {
  return new Promise(function (resolve, reject) {
    Vue.http.post('/taxon_name_classifications', newClassification).then( response => {
      return resolve(response.body);
    });
  });
}

const removeTaxonStatus = function(id) {
  return new Promise(function (resolve, reject) {
    Vue.http.delete(`/taxon_name_classifications/${id}`).then( response => {
      return resolve(response.body);
    });
  });
}

const createTaxonRelationship = function(relationship) {
  return new Promise(function (resolve, reject) {
    Vue.http.post(`/taxon_name_relationships`, relationship).then( response => {
      return resolve(response.body);
    }, response => {
      return reject(response.body);
    });
  });
}

const removeTaxonRelationship = function(relationship) {
  return new Promise(function (resolve, reject) {
    Vue.http.delete(`/taxon_name_relationships/${relationship.id}`).then( response => {
      return resolve(response.body);
    }, response => {
      return reject(response.body);
    });
  });
}

const removeTaxonSource = function(id) {
  return new Promise(function (resolve, reject) {
    let taxon_name = { 
      taxon_name: {
        id: id,
        origin_citation_attributes: {
          _destroy: true
        }
      }
    }

    Vue.http.patch(`/taxon_names/${id}`, taxon_name).then( response => {
      return resolve(response.body);
    });
  });
}

export {
  saveNewTaxonStatus,
  removeTaxonStatus,
  removeTaxonSource,
  removeTaxonRelationship,
  createTaxonRelationship
}