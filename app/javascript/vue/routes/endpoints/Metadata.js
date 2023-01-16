import AjaxCall from 'helpers/ajaxCall'

export const Metadata = {
  relatedSummary: params => AjaxCall('post', '/metadata/related_summary', params),

  annotators: () => AjaxCall('get', '/metadata/annotators')
}
