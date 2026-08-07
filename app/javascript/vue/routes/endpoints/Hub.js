import AjaxCall from '@/helpers/ajaxCall'

export const Hub = {
  all: (params) => AjaxCall('get', '/hub.json', { params })
}
