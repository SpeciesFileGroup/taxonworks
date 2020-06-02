import ajaxCall from 'helpers/ajaxCall'

const GetStatusMetadata = () => {
  return ajaxCall('get', '/taxon_name_classifications/taxon_name_classification_types')
}

const GetRelationshipsMetadata = () => {
  return ajaxCall('get', '/taxon_name_relationships/taxon_name_relationship_types')
}

const GetTaxonNames = (params) => {
  return ajaxCall('get', '/taxon_names.json', { params: params })
}

const GetTaxonName = (id) => {
  return ajaxCall('get', `/taxon_names/${id}.json`)
}

export {
  GetStatusMetadata,
  GetRelationshipsMetadata,
  GetTaxonNames,
  GetTaxonName
}