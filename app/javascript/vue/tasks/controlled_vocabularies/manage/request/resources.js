import AjaxCall from 'helpers/ajaxCall'

const CreateControlledVocabularyTerm = (ctv) => {
  return AjaxCall('post', '/controlled_vocabulary_terms.json', { controlled_vocabulary_term: ctv })
}

const DestroyControlledVocabularyTerm = (id) => {
  return AjaxCall('delete', `/controlled_vocabulary_terms/${id}.json`)
}

const GetControlledVocabularyTerm = (id) => {
  return AjaxCall('get', `/controlled_vocabulary_terms/${id}.json`)
}

const GetControlledVocabularyTerms = (param) => {
  return AjaxCall('get', `/controlled_vocabulary_terms.json`, { params: param })
}

const UpdateControlledVocabularyTerm = (ctv) => {
  return AjaxCall('patch', `/controlled_vocabulary_terms/${ctv.id}.json`, { controlled_vocabulary_term: ctv })
}

export {
  CreateControlledVocabularyTerm,
  DestroyControlledVocabularyTerm,
  GetControlledVocabularyTerm,
  GetControlledVocabularyTerms,
  UpdateControlledVocabularyTerm
}