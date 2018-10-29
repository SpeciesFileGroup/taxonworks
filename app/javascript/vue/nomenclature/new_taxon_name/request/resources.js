import Vue from 'vue'
import VueResource from 'vue-resource'

Vue.use(VueResource)

const init = function () {
  var token = $('[name="csrf-token"]').attr('content')
  Vue.http.headers.common['X-CSRF-Token'] = token
}



const createTaxonName = function (taxon) {
  return new Promise(function (resolve, reject) {
    var taxon_name = {
      taxon_name: {
        name: taxon.name,
        parent_id: taxon.parent_id,
        rank_class: taxon.rank_string,
        type: 'Protonym'
      }
    }
    Vue.http.post('/taxon_names.json', taxon_name).then(response => {
      history.pushState(null, null, `/tasks/nomenclature/new_taxon_name/${response.body.id}`)
      TW.workbench.alert.create(`Taxon name ${response.body.object_tag} was successfully created.`, 'notice')
      return resolve(response.body)
    }, response => {
      return reject(response.body)
    })
  })
}

const updateTaxonName = function (taxon) {
  var taxon_name = {
    taxon_name: {
      name: taxon.name,
      parent_id: taxon.parent_id,
      rank_class: taxon.rank_string,
      year_of_publication: taxon.year_of_publication,
      verbatim_author: taxon.verbatim_author,
      etymology: taxon.etymology,
      feminine_name: taxon.feminine_name,
      masculine_name: taxon.masculine_name,
      neuter_name: taxon.neuter_name,
      roles_attributes: taxon.roles_attributes,
      type: 'Protonym'
    }
  }

  return new Promise(function (resolve, reject) {
    Vue.http.patch(`/taxon_names/${taxon.id}.json`, taxon_name).then(response => {
      if (!response.body.hasOwnProperty('taxon_name_author_roles')) {
        response.body['taxon_name_author_roles'] = []
      }
      response.body.roles_attributes = []
      TW.workbench.alert.create(`Taxon name ${response.body.object_tag} was successfully updated.`, 'notice')
      return resolve(response.body)
    }, response => {
      return reject(response.body)
    })
  })
}

const loadTaxonName = function (id) {
  return new Promise(function (resolve, reject) {
    Vue.http.get(`/taxon_names/${id}`).then(response => {
      return resolve(response.body)
    }, response => {
      TW.workbench.alert.create('There is no taxon name associated to that ID', 'error')
      return reject(response.body)
    })
  })
}

const updateClassification = function (classification) {
  return new Promise(function (resolve, reject) {
    Vue.http.patch(`/taxon_name_classifications/${classification.taxon_name_classification.id}`, classification).then(response => {
      return resolve(response.body)
    })
  })
}

const updateTaxonRelationship = function (relationship) {
  return new Promise(function (resolve, reject) {
    Vue.http.patch(`/taxon_name_relationships/${relationship.taxon_name_relationship.id}`, relationship).then(response => {
      return resolve(response.body)
    })
  })
}

const createTaxonStatus = function (newClassification) {
  return new Promise(function (resolve, reject) {
    Vue.http.post('/taxon_name_classifications', newClassification).then(response => {
      return resolve(response.body)
    }, response => {
      return reject(response.body)
    })
  })
}

const removeTaxonStatus = function (id) {
  return new Promise(function (resolve, reject) {
    Vue.http.delete(`/taxon_name_classifications/${id}`).then(response => {
      return resolve(response.body)
    })
  })
}

const createTaxonRelationship = function (relationship) {
  return new Promise(function (resolve, reject) {
    Vue.http.post(`/taxon_name_relationships`, relationship).then(response => {
      return resolve(response.body)
    }, response => {
      return reject(response.body)
    })
  })
}

const loadSoftValidation = function (global_id) {
  return new Promise(function (resolve, reject) {
    Vue.http.get(`/soft_validations/validate?global_id=${global_id}`).then(response => {
      return resolve(response.body.validations.soft_validations)
    }, response => {
      return reject(response.body)
    })
  })
}

const removeTaxonRelationship = function (relationship) {
  return new Promise(function (resolve, reject) {
    Vue.http.delete(`/taxon_name_relationships/${relationship.id}`).then(response => {
      return resolve(response.body)
    }, response => {
      return reject(response.body)
    })
  })
}

const removeTaxonSource = function (taxonId, citationId) {
  return new Promise(function (resolve, reject) {
    let data = {
      taxon_name: {
        origin_citation_attributes: {
          id: citationId,
          _destroy: true
        }
      }
    }

    Vue.http.patch(`/taxon_names/${taxonId}`, data).then(response => {
      return resolve(response.body)
    })
  })
}

const changeTaxonSource = function (taxonId, source, citation) {
  return new Promise(function (resolve, reject) {
    let data = {
      taxon_name: {
        origin_citation_attributes: {
          id: (citation == undefined ? null : citation.id),
          source_id: source.id,
          is_original: true,
          pages: (source == undefined ? null : source.pages)
        }
      }
    }
    Vue.http.patch(`/taxon_names/${taxonId}`, data).then(response => {
      return resolve(response.body)
    })
  })
}

const loadRanks = function () {
  return new Promise(function (resolve, reject) {
    Vue.http.get('/taxon_names/ranks').then(response => {
      return resolve(response.body)
    }, response => {
      return reject(response.body)
    })
  })
}

const loadStatus = function () {
  return new Promise(function (resolve, reject) {
    Vue.http.get('/taxon_name_classifications/taxon_name_classification_types').then(response => {
      return resolve(response.body)
    }, response => {
      return reject(response.body)
    })
  })
}

const loadRelationships = function () {
  return new Promise(function (resolve, reject) {
    Vue.http.get('/taxon_name_relationships/taxon_name_relationship_types').then(response => {
      return resolve(response.body)
    }, response => {
      return reject(response.body)
    })
  })
}

const loadTaxonStatus = function (id) {
  return new Promise(function (resolve, reject) {
    Vue.http.get(`/taxon_names/${id}/taxon_name_classifications`).then(response => {
      return resolve(response.body)
    }, response => {
      return reject(response.body)
    })
  })
}

const loadTaxonRelationships = function (id) {
  return new Promise(function (resolve, reject) {
    Vue.http.get(`/taxon_names/${id}/taxon_name_relationships?as_subject=true&of_type[]=synonym&of_type[]=status`).then(response => {
      return resolve(response.body)
    }, response => {
      return reject(response.body)
    })
  })
}

export {
  init,
  createTaxonName,
  updateTaxonName,
  updateClassification,
  updateTaxonRelationship,
  loadTaxonName,
  loadRanks,
  loadStatus,
  loadRelationships,
  loadTaxonStatus,
  loadTaxonRelationships,
  loadSoftValidation,
  createTaxonStatus,
  removeTaxonStatus,
  removeTaxonSource,
  removeTaxonRelationship,
  createTaxonRelationship,
  changeTaxonSource
}
