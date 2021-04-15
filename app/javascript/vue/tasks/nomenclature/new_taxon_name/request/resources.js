import ajaxCall from 'helpers/ajaxCall'

const createTaxonName = (taxon) => ajaxCall('post', '/taxon_names.json', taxon)

const updateTaxonName = (taxon) => ajaxCall('patch', `/taxon_names/${taxon.id}.json`, { taxon_name: taxon })

const loadTaxonName = (id) => ajaxCall('get', `/taxon_names/${id}.json`)

const updateClassification = (classification) => ajaxCall('patch', `/taxon_name_classifications/${classification.taxon_name_classification.id}`, classification)

const updateTaxonRelationship = (relationship) => ajaxCall('patch', `/taxon_name_relationships/${relationship.taxon_name_relationship.id}`, relationship)

const createTaxonStatus = (newClassification) => ajaxCall('post', '/taxon_name_classifications', newClassification)

const updateTaxonStatus = (newClassification) => ajaxCall('patch', `/taxon_name_classifications/${newClassification.taxon_name_classification.id}.json`, newClassification)

const removeTaxonStatus = (id) => ajaxCall('delete', `/taxon_name_classifications/${id}`)

const createTaxonRelationship = (relationship) => ajaxCall('post', '/taxon_name_relationships', relationship)

const loadSoftValidation = (globalId) => ajaxCall('get', '/soft_validations/validate', { params: { global_id: globalId } })

const removeTaxonRelationship = (relationship) => ajaxCall('delete', `/taxon_name_relationships/${relationship.id}`)

const loadRanks = () => ajaxCall('get', '/taxon_names/ranks')

const GetTypeMaterial = (taxonId) => ajaxCall('get', `/type_materials.json?protonym_id=${taxonId}`)

const loadStatus = () => ajaxCall('get', '/taxon_name_classifications/taxon_name_classification_types')

const loadRelationships = () => ajaxCall('get', '/taxon_name_relationships/taxon_name_relationship_types')

const loadTaxonStatus = (id) => ajaxCall('get', `/taxon_names/${id}/taxon_name_classifications`)

const loadTaxonRelationships = (id) => ajaxCall('get', `/taxon_names/${id}/taxon_name_relationships.json`, {
  params: {
    as_subject: true,
    taxon_name_relationship_set: [
      'synonym',
      'status',
      'classification']
  }
})

const GetPredictedRank = (parentId, name) => ajaxCall('get', `/taxon_names/predicted_rank`, { params: { parent_id: parentId, name: name }})

const SoftValidationFix = (params) => ajaxCall('post', `/soft_validations/fix?global_id=${params.global_id}`, params)

export {
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
  updateTaxonStatus,
  removeTaxonRelationship,
  createTaxonRelationship,
  GetTypeMaterial,
  GetPredictedRank,
  SoftValidationFix
}
