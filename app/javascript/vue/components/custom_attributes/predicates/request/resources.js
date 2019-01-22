import ajaxCall from 'helpers/ajaxCall'

const GetProjectPreferences = function () {
  return ajaxCall('get', `/project_preferences.json`)
}

const GetPredicates = function (ids) {
  return ajaxCall('get', '/controlled_vocabulary_terms', { params: { 'of_type[]': 'Predicate', 'id': ids } })
}

const GetPredicatesCreated = function (objectType, objectId) {
  return ajaxCall('get', `/data_attributes?attribute_subject_type=${objectType}&attribute_subject_id=${objectId}&type=InternalAttribute`)
}

export {
  GetPredicates,
  GetPredicatesCreated,
  GetProjectPreferences
}