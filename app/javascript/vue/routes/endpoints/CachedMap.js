import ajaxCall from 'helpers/ajaxCall'

export const CachedMap = {
  find: (id) => ajaxCall('get', `/cached_maps/${id}`)
}
