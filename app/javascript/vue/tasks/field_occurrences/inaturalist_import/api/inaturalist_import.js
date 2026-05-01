import AjaxCall from '@/helpers/ajaxCall'

const BASE = '/tasks/field_occurrences/inaturalist_import'

export default {
  submit(params) {
    return AjaxCall('post', `${BASE}/submit.json`, params)
  },

  recent() {
    return AjaxCall('get', `${BASE}/recent.json`)
  }
}
