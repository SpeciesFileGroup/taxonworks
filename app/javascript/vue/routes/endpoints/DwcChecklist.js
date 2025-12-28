import AjaxCall from '@/helpers/ajaxCall'

const controller = 'tasks/dwc/dashboard'

export const DwcChecklist = {
  checklistExtensions: () =>
    AjaxCall('get', `/${controller}/checklist_extensions`),

  generateChecklistDownload: (params) =>
    AjaxCall('post', `/${controller}/generate_checklist_download.json`, params)
}
