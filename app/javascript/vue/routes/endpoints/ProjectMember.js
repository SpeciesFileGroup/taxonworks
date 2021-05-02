import baseCRUD from './base'
import AjaxCall from 'helpers/ajaxCall'

const controller = 'project_members'
const permitParams = {
  project_member: {
    project_id: Number,
    user_id: Number,
    is_project_administrator: Boolean
  }
}

export const ProjectMember = {
  ...baseCRUD(controller, permitParams),

  updateClipboard: (params) => AjaxCall('put', `/${controller}/update_clipboard.json`, { project_member: { clipboard: params } }),

  clipboard: () => AjaxCall('get', `/${controller}/clipboard.json`)
}
