import ajaxCall from 'helpers/ajaxCall'

const GetPredicates = function () {
  return ajaxCall('get', '/controlled_vocabulary_terms.json?type[]=Predicate')
}

const GetProjectPreferences = function () {
  return ajaxCall('get', '/project_preferences.json')
}

const UpdateProjectPreferences = function (id, preferences) {
  return ajaxCall('patch', `/projects/${id}.json`, { project: preferences })
}

const CreateControlledVocabularyTerm = function (label) {
  return ajaxCall('post', '/controlled_vocabulary_terms', { controlled_vocabulary_term: label })
}

export {
  CreateControlledVocabularyTerm,
  GetPredicates,
  GetProjectPreferences,
  UpdateProjectPreferences
}