import AjaxCall from '@/helpers/ajaxCall'

export const ColdpExportPreference = {
  preferences: (id) =>
    AjaxCall('get', `/projects/${id}/coldp_export_preferences/preferences.json`),

  saveProfile: (id, params) =>
    AjaxCall('post', `/projects/${id}/coldp_export_preferences/save_profile.json`, params),

  destroyProfile: (id, params) =>
    AjaxCall('delete', `/projects/${id}/coldp_export_preferences/destroy_profile.json`, { params }),

  saveColdpSettings: (id, params) =>
    AjaxCall('post', `/projects/${id}/coldp_export_preferences/save_coldp_settings.json`, params),

  validateMetadata: (id, params) =>
    AjaxCall('post', `/projects/${id}/coldp_export_preferences/validate_metadata.json`, params),

  controlledVocabularyStatus: (id) =>
    AjaxCall('get', `/projects/${id}/coldp_export_preferences/controlled_vocabulary_status.json`),

  createMissingPredicates: (id) =>
    AjaxCall('post', `/projects/${id}/coldp_export_preferences/create_missing_predicates.json`),

  createPredicate: (id, params) =>
    AjaxCall('post', `/projects/${id}/coldp_export_preferences/create_predicate.json`, params),

  missingOtusCount: (id, params) =>
    AjaxCall('get', `/projects/${id}/coldp_export_preferences/missing_otus_count.json`, { params }),

  bulkSetExtinct: (id, params) =>
    AjaxCall('post', `/projects/${id}/coldp_export_preferences/bulk_set_extinct.json`, params),

  bulkSetLifezone: (id, params) =>
    AjaxCall('post', `/projects/${id}/coldp_export_preferences/bulk_set_lifezone.json`, params),

  checklistbankCitation: (id, params) =>
    AjaxCall('get', `/projects/${id}/coldp_export_preferences/checklistbank_citation.json`, { params }),

  checklistbankImports: (id, params) =>
    AjaxCall('get', `/projects/${id}/coldp_export_preferences/checklistbank_imports.json`, { params }),

  checklistbankIssues: (id, params) =>
    AjaxCall('get', `/projects/${id}/coldp_export_preferences/checklistbank_issues.json`, { params }),

  fetchClbMetadata: (id, params) =>
    AjaxCall('get', `/projects/${id}/coldp_export_preferences/fetch_clb_metadata.json`, { params }),

  checklistbankDuplicates: (id, params) =>
    AjaxCall('get', `/projects/${id}/coldp_export_preferences/checklistbank_duplicates.json`, { params }),

  checklistbankDiff: (id, params) =>
    AjaxCall('get', `/projects/${id}/coldp_export_preferences/checklistbank_diff.json`, { params }),

  bulkLoadIssueTags: (id, params) =>
    AjaxCall('post', `/projects/${id}/coldp_export_preferences/bulk_load_issue_tags.json`, params),

  cleanupIssueTags: (id) =>
    AjaxCall('post', `/projects/${id}/coldp_export_preferences/cleanup_issue_tags.json`),

  coldpIssueKeywords: (id) =>
    AjaxCall('get', `/projects/${id}/coldp_export_preferences/coldp_issue_keywords.json`)
}
