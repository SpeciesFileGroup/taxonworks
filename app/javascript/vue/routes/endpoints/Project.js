import baseCRUD, { annotations } from './base'
import AjaxCall from 'helpers/ajaxCall'

const permitParams = {
  project: Object
}

export const Project = {
  ...baseCRUD('projects', permitParams),

  ...annotations('projects'),

  preferences: () => AjaxCall('get', '/project_preferences.json')
}
