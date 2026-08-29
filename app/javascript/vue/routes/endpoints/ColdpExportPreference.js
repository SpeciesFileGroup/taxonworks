import AjaxCall from '@/helpers/ajaxCall'

export const ColdpExportPreference = {
  preferences: (id) =>
    AjaxCall('get', `/projects/${id}/coldp_export_preferences/preferences.json`),

  createProfile: (id, params) =>
    AjaxCall('post', `/projects/${id}/coldp_profiles.json`, params),

  updateProfile: (id, otuId, params) =>
    AjaxCall('patch', `/projects/${id}/coldp_profiles/${otuId}.json`, params),

  destroyProfile: (id, otuId) =>
    AjaxCall('delete', `/projects/${id}/coldp_profiles/${otuId}.json`),

  validateProfile: (id, params) =>
    AjaxCall('patch', `/projects/${id}/coldp_profiles/validate.json`, params),

  updateSettings: (id, params) =>
    AjaxCall('patch', `/projects/${id}/coldp_settings.json`, params),

  controlledVocabularyStatus: (id) =>
    AjaxCall('get', `/projects/${id}/coldp_export_preferences/controlled_vocabulary_status.json`),

  createMissingPredicates: (id) =>
    AjaxCall('post', `/projects/${id}/coldp_export_preferences/create_missing_predicates.json`),

  createPredicate: (id, params) =>
    AjaxCall('post', `/projects/${id}/coldp_export_preferences/create_predicate.json`, params),

  missingOtusCount: (id, params) =>
    AjaxCall('get', `/projects/${id}/coldp_export_preferences/missing_otus_count.json`, { params }),

  checklistbankCitation: (id, params) =>
    AjaxCall('get', `/projects/${id}/coldp_export_preferences/checklistbank_citation.json`, { params }),

  checklistbankIssues: (id, params) =>
    AjaxCall('get', `/projects/${id}/coldp_export_preferences/checklistbank_issues.json`, { params }),

  fetchChecklistbankMetadata: (id, params) =>
    AjaxCall('get', `/projects/${id}/coldp_export_preferences/fetch_checklistbank_metadata.json`, { params }),

  searchDatasets: (id, params) =>
    AjaxCall('get', `/projects/${id}/coldp_export_preferences/search_datasets.json`, { params }),

  issueVocab: (id) =>
    AjaxCall('get', `/projects/${id}/coldp_export_preferences/issue_vocab.json`)
}
