import ajaxCall from 'helpers/ajaxCall'

const GetCollectionObjects = (params) => {
  return ajaxCall('get', '/collection_objects.json', { params: params })
}

const GetUsers = () => {
  return ajaxCall('get', '/project_members.json')
}

const GetCollectingEventSmartSelector = () => {
  return ajaxCall('get', '/collecting_events/select_options')
}

const GetKeywordSmartSelector = () => {
  return ajaxCall('get', '/keywords/select_options?klass=CollectionObject')
}

const GetNamespacesSmartSelector = () => {
  return ajaxCall('get', '/namespaces/select_options')
}

const GetCEAttributes = () => {
  return ajaxCall('get', `/collecting_events/attributes`)
}

const GetTypes = function () {
  return ajaxCall('get', `/type_materials/type_types.json`)
}

const GetRelationshipsMetadata = () => {
  return ajaxCall('get', '/taxon_name_relationships/taxon_name_relationship_types')
}

const GetBiocurations = () => {
  return ajaxCall('get', '/controlled_vocabulary_terms.json?type[]=BiocurationClass')
}

export {
  GetCollectionObjects,
  GetUsers,
  GetCollectingEventSmartSelector,
  GetKeywordSmartSelector,
  GetNamespacesSmartSelector,
  GetCEAttributes,
  GetTypes,
  GetRelationshipsMetadata,
  GetBiocurations
}
