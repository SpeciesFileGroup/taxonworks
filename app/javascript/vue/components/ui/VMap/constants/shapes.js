import {
  COLLECTION_OBJECT,
  FIELD_OCCURRENCE,
  TYPE_MATERIAL,
  ASSERTED_DISTRIBUTION,
  GEOREFERENCE,
  GEOGRAPHIC_AREA,
  MAP_SHAPE_AGGREGATE
} from '@/constants'
import { DISABLE_LAYER_OPTIONS } from './disableLayerOptions'

const DEFAULT_SHAPE_STYLE = {
  weight: 2,
  dashArray: '3',
  dashOffset: '3',
  fillOpacity: 0.5
}

export const SHAPES_CONFIG = {
  Absent: {
    className: 'leaflet-hatch-pattern',
    color: '#a1ff66'
  },

  [ASSERTED_DISTRIBUTION]: {
    options: {
      ...DISABLE_LAYER_OPTIONS
    },
    style: {
      color: 'var(--color-map-asserted-distribution)',
      ...DEFAULT_SHAPE_STYLE
    }
  },

  [GEOGRAPHIC_AREA]: {
    options: {
      ...DISABLE_LAYER_OPTIONS
    },
    style: {
      color: 'var(--color-map-asserted-distribution)',
      ...DEFAULT_SHAPE_STYLE
    }
  },

  [MAP_SHAPE_AGGREGATE]: {
    options: {
      ...DISABLE_LAYER_OPTIONS
    },
    style: {
      color: 'var(--color-map-aggregate)',
      ...DEFAULT_SHAPE_STYLE
    }
  },

  [COLLECTION_OBJECT]: {
    style: {
      color: `var(--color-map-collection-object)`,
      weight: 1,
      fillOpacity: 0.5
    }
  },

  [GEOREFERENCE]: {
    style: {
      color: `var(--color-map-collection-object)`,
      ...DEFAULT_SHAPE_STYLE
    }
  },

  [FIELD_OCCURRENCE]: {
    style: {
      color: `var(--color-map-field-occurrence)`,
      ...DEFAULT_SHAPE_STYLE
    }
  },

  [TYPE_MATERIAL]: {
    style: {
      color: `var(--color-map-type-material)`,
      ...DEFAULT_SHAPE_STYLE
    }
  }
}
