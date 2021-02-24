import ajaxCall from 'helpers/ajaxCall'

const GetCollectionObjects = (params) => {
  return ajaxCall('get', '/collection_objects/dwc_index', { params: params })
}

const GetCollectingEvents = (id) => {
  return ajaxCall('get', `/collecting_events/${id}.json`)
}

const GetUsers = () => {
  return ajaxCall('get', '/project_members.json')
}

const GetGeographicArea = (id) => {
  return ajaxCall('get', `/geographic_areas/${id}.json`)
}

const GetTaxonName = (id) => {
  return ajaxCall('get', `/taxon_names/${id}.json`)
}

const GetNamespace = (id) => {
  return ajaxCall('get', `/namespaces/${id}.json`)
}

const GetRepository = (id) => {
  return ajaxCall('get', `/repositories/${id}.json`)
}

const GetOtu = (id) => {
  return ajaxCall('get', `/otus/${id}.json`)
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

const GetKeyword = (id) => {
  return ajaxCall('get', `/controlled_vocabulary_terms/${id}.json`)
}

const GetCODWCA = (id) => {
  return ajaxCall('get', `/collection_objects/${id}/dwc`)
}

const CreateTags = (keywordId, ids, type) => {
  return ajaxCall('post', `/tags/batch_create`, { 
    object_type: type,
    keyword_id: keywordId,
    object_ids: ids
  })
}

export {
  GetCollectionObjects,
  GetUsers,
  GetCEAttributes,
  GetTypes,
  GetBiologicalRelationships,
  GetBiocurations,
  GetCODWCA,
  CreateTags,
  GetGeographicArea,
  GetTaxonName,
  GetOtu,
  GetNamespace,
  GetCollectingEvents,
  GetKeyword,
  GetRepository
}
