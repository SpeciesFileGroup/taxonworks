import ajaxCall from 'helpers/ajaxCall'

const GetProjectPreferences = () => ajaxCall('get', '/project_preferences.json')

const GetPredicates = (ids) => ajaxCall('get', '/controlled_vocabulary_terms.json', { params: { type: ['Predicate'], id: ids } })

const GetPredicatesCreated = (objectType, objectId) => ajaxCall('get', '/data_attributes.json', {
  attribute_subject_type: objectType,
  attribute_subject_id: objectId,
  type: 'InternalAttribute'
})

export {
  GetPredicates,
  GetPredicatesCreated,
  GetProjectPreferences
}
