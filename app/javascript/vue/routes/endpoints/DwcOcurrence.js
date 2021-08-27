import AjaxCall from 'helpers/ajaxCall'

export const DwcOcurrence = {
  metadata: params => AjaxCall('get', '/dwc_occurrences/metadata.json', { params }),

  generateDownload: params => AjaxCall('post', '/tasks/dwc/dashboard/generate_download.json', params),

  createIndex: params => AjaxCall('post', '/tasks/dwc/dashboard/create_index', params),
}
