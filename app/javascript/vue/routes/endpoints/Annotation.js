import ajaxCall from 'helpers/ajaxCall'

export const Annotation = {
  metadata: globalId => ajaxCall('get', `/annotations/${encodeURIComponent(globalId)}/metadata`)
}
