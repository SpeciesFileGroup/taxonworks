import AjaxCall from '@/helpers/ajaxCall'

const STATUS_TIMEOUT = 15000

export const Session = {
  status: () =>
    AjaxCall('get', '/session_status.json', { timeout: STATUS_TIMEOUT })
}
