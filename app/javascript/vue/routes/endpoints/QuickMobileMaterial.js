import AjaxCall from '@/helpers/ajaxCall'

const path = '/tasks/collection_objects/quick_mobile_material'

// Session authenticated endpoints of the Quick mobile material task. The
// token-authenticated capture endpoint is called by the Mobile app only.
export const QuickMobileMaterial = {
  // Issues a new task_token, returns a server-rendered QR code (SVG)
  issueTaskToken: (params) =>
    AjaxCall('post', `${path}/task_token.json`, params),

  invalidateTaskToken: () => AjaxCall('delete', `${path}/task_token.json`),

  taskTokenStatus: () => AjaxCall('get', `${path}/task_token.json`),

  items: (params) => AjaxCall('get', `${path}/items.json`, { params })
}
