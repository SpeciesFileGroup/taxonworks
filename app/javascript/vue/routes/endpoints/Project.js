import baseCRUD, { annotations } from './base'
import AjaxCall from '@/helpers/ajaxCall'

const permitParams = {
  project: Object
}

const controller = 'projects'
export const Project = {
  ...baseCRUD('projects', permitParams),

  ...annotations('projects'),

  preferences: () => AjaxCall('get', '/project_preferences.json'),

  completeDownloadIsPublic: () =>
    AjaxCall('get', `/${controller}/complete_download_is_public.json`),

  completeDownloadPreferences: () =>
    AjaxCall('get', `/${controller}/complete_download_preferences.json`)
}
