import { ajaxCall } from '@/helpers'

export const Unify = {
  metadata: (params) => ajaxCall('get', '/unify/metadata', { params }),
  merge: (params) => ajaxCall('post', '/unify', params)
}
