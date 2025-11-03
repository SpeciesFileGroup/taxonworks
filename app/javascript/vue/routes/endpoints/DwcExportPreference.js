import AjaxCall from '@/helpers/ajaxCall'

export const DwcExportPreference = {
  preferences: (id) =>
    AjaxCall('get', `/projects/${id}/dwc_export_preferences/preferences.json`),

  setMaxAge: (id, params) =>
    AjaxCall('post', `/projects/${id}/dwc_export_preferences/set_max_age.json`, params),

  setIsPublic: (id, params) =>
    AjaxCall('post', `/projects/${id}/dwc_export_preferences/set_is_public.json`, params),

  setExtensions: (id, params) =>
    AjaxCall('post', `/projects/${id}/dwc_export_preferences/set_extensions.json`, params),

  setPredicatesAndInternalValues: (id, params) =>
    AjaxCall('post', `/projects/${id}/dwc_export_preferences/set_predicates_and_internal_values.json`, params),

  validateEML: (params) =>
    AjaxCall('post', `/projects/dwc_export_preferences/validate_eml.json`,  params),

  saveEML: (id, params) =>
    AjaxCall('post', `/projects/${id}/dwc_export_preferences/save_eml.json`, params),

  setDefaultUser: (id, params) =>
    AjaxCall('post', `/projects/${id}/dwc_export_preferences/set_default_user.json`, params)


}
