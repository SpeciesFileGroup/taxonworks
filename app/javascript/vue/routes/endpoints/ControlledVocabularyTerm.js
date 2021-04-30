import baseCRUD from './base'

const permitParams = {
  controlled_vocabulary_term: {
    type: String,
    name: String,
    definition: String,
    uri: String,
    uri_relation: String,
    css_color: String
  }
}

export const ControlledVocabularyTerm = {
  ...baseCRUD('controlled_vocabulary_terms', permitParams)
}
