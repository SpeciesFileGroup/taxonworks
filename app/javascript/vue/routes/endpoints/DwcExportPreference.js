import AjaxCall from '@/helpers/ajaxCall'

export const DwcExportPreference = {
  preferences: (id) =>
    AjaxCall('get', `/projects/${id}/dwc_export_preferences/preferences.json`),

  setIsPublic: (id, params) =>
    AjaxCall('post', `/projects/${id}/dwc_export_preferences/set_is_public.json`, params),

  validateEML: (params) =>
    AjaxCall('get', `/projects/dwc_export_preferences/validate_eml.json`, { params }),

  saveEML: (id, params) =>
    AjaxCall('post', `/projects/${id}/dwc_export_preferences/save_eml.json`, params)


}
