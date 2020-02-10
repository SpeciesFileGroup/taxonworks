import ajaxCall from 'helpers/ajaxCall'

const CreateBiologicalRelationship = (data) => {
  return ajaxCall('post', '/biological_relationships', { biological_relationship: data })
}

const CreateProperty = (data) => {
  return ajaxCall('post', '/controlled_vocabulary_terms', { controlled_vocabulary_term: data })
}

const GetBiologicalRelationships = () => {
  return ajaxCall('get', '/biological_relationships.json')
}

const GetProperties = () => {
  return ajaxCall('get', '/controlled_vocabulary_terms.json', { params: { 'type[]': 'BiologicalProperty' }})
}

const UpdateBiologicalRelationship = (data) => {
  return ajaxCall('patch', `/biological_relationships/${data.id}.json`, { biological_relationship: data })
}

const GetBiologicalAssociations = (id) => {
  return ajaxCall('get', '/biological_associations.json', { params: { biological_relationship_id: id, per: 10 } })
}

export {
  CreateBiologicalRelationship,
  CreateProperty,
  GetBiologicalRelationships,
  GetProperties,
  UpdateBiologicalRelationship,
  GetBiologicalAssociations
}