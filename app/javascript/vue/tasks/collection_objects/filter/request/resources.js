import ajaxCall from 'helpers/ajaxCall'

const CreateTags = (keywordId, ids, type) => ajaxCall('post', '/tags/batch_create', {
  object_type: type,
  keyword_id: keywordId,
  object_ids: ids
})

const GetBiocurations = () => ajaxCall('get', '/controlled_vocabulary_terms.json?type[]=BiocurationClass')

const GetBiologicalRelationships = () => ajaxCall('get', '/biological_relationships.json')

const GetCEAttributes = () => ajaxCall('get', '/collecting_events/attributes')

const GetCODWCA = (id) => ajaxCall('get', `/collection_objects/${id}/dwc`)

const GetCollectingEvents = (id) => ajaxCall('get', `/collecting_events/${id}.json`)

const GetCollectionObjects = (params) => ajaxCall('get', '/collection_objects/dwc_index', { params: params })

const GetGeographicArea = (id) => ajaxCall('get', `/geographic_areas/${id}.json`)

const GetKeyword = (id) => ajaxCall('get', `/controlled_vocabulary_terms/${id}.json`)

const GetNamespace = (id) => ajaxCall('get', `/namespaces/${id}.json`)

const GetOtu = (id) => ajaxCall('get', `/otus/${id}.json`)

const GetPerson = (id) => ajaxCall('get', `/people/${id}.json`)

const GetRepository = (id) => ajaxCall('get', `/repositories/${id}.json`)

const GetTaxonName = (id) => ajaxCall('get', `/taxon_names/${id}.json`)

const GetTypes = () => ajaxCall('get', '/type_materials/type_types.json')

const GetUsers = () => ajaxCall('get', '/project_members.json')

export {
  CreateTags,
  GetBiocurations,
  GetBiologicalRelationships,
  GetCEAttributes,
  GetCODWCA,
  GetCollectingEvents,
  GetCollectionObjects,
  GetGeographicArea,
  GetKeyword,
  GetNamespace,
  GetOtu,
  GetPerson,
  GetRepository,
  GetTaxonName,
  GetTypes,
  GetUsers
}
