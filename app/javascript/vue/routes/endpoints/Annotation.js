import ajaxCall from '@/helpers/ajaxCall'

export const Annotation = {
  metadata: (globalId) =>
    ajaxCall('get', `/annotations/${encodeURIComponent(globalId)}/metadata`),

  move: (params) => ajaxCall('post', '/annotations/move', params),

  moveOne: (params) => ajaxCall('post', '/annotations/move_one', params)
}
