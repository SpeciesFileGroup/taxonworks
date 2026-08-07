import { ajaxCall } from '@/helpers'
import baseCRUD from './base'

const controller = 'controlled_vocabulary_terms'

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
  ...baseCRUD('controlled_vocabulary_terms', permitParams),

  cloneFromProject: (params) =>
    ajaxCall('post', `/${controller}/clone_from_project`, params)
}
