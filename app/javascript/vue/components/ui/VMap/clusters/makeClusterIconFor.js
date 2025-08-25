import * as ClusterType from './Mixed.js'

export function makeClusterIconFor({ L, cluster }) {
  return L.divIcon(ClusterType.Mixed(cluster))
}
