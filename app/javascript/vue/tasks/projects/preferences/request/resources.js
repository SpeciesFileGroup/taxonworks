import ajaxCall from 'helpers/ajaxCall'

const GetPredicates = () => ajaxCall('get', '/controlled_vocabulary_terms.json?type[]=Predicate')

const GetProjectPreferences = () => ajaxCall('get', '/project_preferences.json')

const UpdateProjectPreferences = (id, preferences) => ajaxCall('patch', `/projects/${id}.json`, { project: preferences })

const CreateControlledVocabularyTerm = (label) => ajaxCall('post', '/controlled_vocabulary_terms', { controlled_vocabulary_term: label })

export {
  CreateControlledVocabularyTerm,
  GetPredicates,
  GetProjectPreferences,
  UpdateProjectPreferences
}