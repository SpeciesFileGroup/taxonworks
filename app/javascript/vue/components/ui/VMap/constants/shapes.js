import {
  COLLECTION_OBJECT,
  FIELD_OCCURRENCE,
  TYPE_MATERIAL,
  ASSERTED_DISTRIBUTION,
  GEOREFERENCE,
  GEOGRAPHIC_AREA
} from '@/constants'
import { DISABLE_LAYER_OPTIONS } from './disableLayerOptions'

const DEFAULT_SHAPE_STYLE = {
  weight: 2,
  dashArray: '3',
  dashOffset: '3',
  fillOpacity: 0.25
}

export const SHAPES_CONFIG = {
  [ASSERTED_DISTRIBUTION]: {
    options: {
      ...DISABLE_LAYER_OPTIONS
    },
    style: {
      color: 'rgb(var(--color-map-asserted))',
      ...DEFAULT_SHAPE_STYLE
    }
  },

  [GEOGRAPHIC_AREA]: {
    options: {
      ...DISABLE_LAYER_OPTIONS
    },
    style: {
      color: 'rgb(var(--color-map-asserted))',
      ...DEFAULT_SHAPE_STYLE
    }
  },
  /* 
  [AGGREGATE]: {
    options: {
      ...DISABLE_LAYER_OPTIONS
    },
    style: {
      color: 'rgb(var(--color-map-aggregate))',
      ...DEFAULT_SHAPE_STYLE
    }
  }, */

  [COLLECTION_OBJECT]: {
    style: {
      color: `rgb(var(--color-map-collection-object))`,
      weight: 1,
      fillOpacity: 'var(--color-map-shape-opacity)'
    }
  },

  [GEOREFERENCE]: {
    style: {
      color: `rgb(var(--color-map-collection-object))`,
      ...DEFAULT_SHAPE_STYLE
    }
  },

  [FIELD_OCCURRENCE]: {
    style: {
      color: `rgb(var(--color-map-field-occurrence))`,
      ...DEFAULT_SHAPE_STYLE
    }
  },

  [TYPE_MATERIAL]: {
    style: {
      color: `rgb(var(--color-map-type-material))`,
      ...DEFAULT_SHAPE_STYLE
    }
  }
}
