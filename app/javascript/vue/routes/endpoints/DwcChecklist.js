import AjaxCall from '@/helpers/ajaxCall'

const controller = 'tasks/dwc/dashboard'

export const DwcChecklist = {
  checklistExtensions: () =>
    AjaxCall('get', `/${controller}/checklist_extensions`),

  acceptedNameModeOptions: () =>
    AjaxCall('get', `/${controller}/accepted_name_mode_options`),

  generateChecklistDownload: (params) =>
    AjaxCall('post', `/${controller}/generate_checklist_download.json`, params)
}
