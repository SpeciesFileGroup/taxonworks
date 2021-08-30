import AjaxCall from 'helpers/ajaxCall'

export const DwcOcurrence = {
  indexVersion: () => AjaxCall('get', '/dwc_occurrences/dwc/dashboard/index_versions'),

  metadata: params => AjaxCall('get', '/dwc_occurrences/metadata.json', { params }),

  generateDownload: params => AjaxCall('post', '/tasks/dwc/dashboard/generate_download.json', params),

  createIndex: params => AjaxCall('post', '/tasks/dwc/dashboard/create_index', params)
}
