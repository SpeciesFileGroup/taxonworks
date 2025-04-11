import L from 'leaflet'
import {
  COLLECTION_OBJECT,
  FIELD_OCCURRENCE,
  TYPE_MATERIAL,
  ASSERTED_DISTRIBUTION,
  GEOREFERENCE
} from '@/constants'

const defaultProperties = {
  iconSize: [8, 8],
  iconAnchor: [4, 4]
}

const Icon = {
  [COLLECTION_OBJECT]: {
    className: 'map-point-marker bg-collection-object',
    ...defaultProperties
  },
  [FIELD_OCCURRENCE]: {
    className: 'map-point-marker bg-field-occurrence',
    ...defaultProperties
  },
  [TYPE_MATERIAL]: {
    className: 'map-point-marker bg-type-material',
    ...defaultProperties
  },
  [ASSERTED_DISTRIBUTION]: {
    className: 'map-point-marker bg-asserted-distribution',
    ...defaultProperties
  },
  [GEOREFERENCE]: {
    className: 'map-point-marker bg-georeference',
    ...defaultProperties
  }
}

export { Icon }
