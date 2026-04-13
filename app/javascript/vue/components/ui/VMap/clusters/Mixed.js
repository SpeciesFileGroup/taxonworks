import { makeSegmentedCircle } from '../utils/makeSegmentedCircle.js'
import {
  COLLECTION_OBJECT,
  FIELD_OCCURRENCE,
  TYPE_MATERIAL
} from '@/constants'

export function Mixed(cluster) {
  const sliceColor = {
    [FIELD_OCCURRENCE]: 'leaflet-cluster-field-occurrence',
    [COLLECTION_OBJECT]: 'leaflet-cluster-collection-object',
    [TYPE_MATERIAL]: 'leaflet-cluster-type-material'
  }

  const markers = cluster.getAllChildMarkers()
  const types = markers.map((l) =>
    l.feature.properties.base.map((item) => item.type)
  )
  const uniqueTypes = [...new Set(types.flat())]
  const segments = uniqueTypes.map((type) => ({
    class: sliceColor[type]
  }))

  const circle = makeSegmentedCircle({
    attributes: {
      class: 'leaflet-cluster-outter-circle'
    },
    segments
  })

  const innerCircle = makeSegmentedCircle({
    attributes: {
      class: 'leaflet-cluster-inner-circle'
    },
    segments
  })

  return {
    html: [
      circle,
      innerCircle,
      `<span class="leaflet-cluster-label">
        ${cluster.getChildCount()}
      </span>
      `
    ].join(''),
    className: 'leaflet-marker-icon leaflet-zoom-animated leaflet-interactive',
    iconSize: [40, 40]
  }
}
