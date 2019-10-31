import ajaxCall from 'helpers/ajaxCall'

const GetCollectionObjects = (params) => {
  return ajaxCall('get', '/collection_objects/dwc_index', { params: params })
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

const GetBiologicalRelationships = () => {
  return ajaxCall('get', '/biological_relationships.json')
}

const GetBiocurations = () => {
  return ajaxCall('get', '/controlled_vocabulary_terms.json?type[]=BiocurationClass')
}

const GetCODWCA = (id) => {
  return ajaxCall('get', `/collection_objects/${id}/dwc`)
}

const CreateTags = (keywordId, ids) => {
  return ajaxCall('post', `/tags/batch_create`, { 
    object_type: 'CollectionObject',
    keyword_id: keywordId,
    object_ids: ids
  })
}

export {
  GetCollectionObjects,
  GetUsers,
  GetCollectingEventSmartSelector,
  GetKeywordSmartSelector,
  GetNamespacesSmartSelector,
  GetCEAttributes,
  GetTypes,
  GetBiologicalRelationships,
  GetBiocurations,
  GetCODWCA,
  CreateTags
}
