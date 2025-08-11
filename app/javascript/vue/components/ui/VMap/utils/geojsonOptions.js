import { ICONS, SHAPES_CONFIG } from '../constants'
import {
  TYPE_MATERIAL,
  COLLECTION_OBJECT,
  ASSERTED_DISTRIBUTION,
  GEOREFERENCE,
  MAP_SHAPE_AGGREGATE
} from '@/constants'

const TYPES = [
  TYPE_MATERIAL,
  COLLECTION_OBJECT,
  ASSERTED_DISTRIBUTION,
  GEOREFERENCE,
  MAP_SHAPE_AGGREGATE
]

function getRelevantType(base) {
  const types = base.map((b) => b.type)

  types.sort((a, b) => TYPES.indexOf(a) - TYPES.indexOf(b))

  return types[0]
}

export default ({ L }) => ({
  onEachFeature: (feature, layer) => {
    const shapeType = feature.properties.shape?.type
    const layerConfiguration =
      feature.properties.options || SHAPES_CONFIG[shapeType]

    if (feature.properties?.popup) {
      layer.bindPopup(feature.properties.popup)
    }

    layer.pm.setOptions(layerConfiguration)
    layer.pm.disable()
  },

  pointToLayer: (feature, latLng) => {
    const base = feature.properties.base
    const type = base ? getRelevantType(feature.properties.base) : null
    const radius = feature.properties.radius
    const markerStyle = ICONS[type] || ICONS[GEOREFERENCE]
    const marker = radius
      ? L.circle(latLng, Number(radius))
      : L.marker(latLng, {
          icon: L.divIcon({
            ...markerStyle,
            ...feature.properties.style
          })
        })

    return marker
  },

  style: (feature) => {
    const base = feature.properties.base
    const type = base ? getRelevantType(base) : null
    const style = feature.properties.style || SHAPES_CONFIG[type]?.style
    const isAbsent = feature.properties.is_absent

    return isAbsent ? { ...style, ...SHAPES_CONFIG.Absent } : style
  }
})
