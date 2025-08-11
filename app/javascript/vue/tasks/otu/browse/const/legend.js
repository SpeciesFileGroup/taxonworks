import {
  FIELD_OCCURRENCE,
  TYPE_MATERIAL,
  COLLECTION_OBJECT,
  GEOREFERENCE,
  ASSERTED_DISTRIBUTION,
  MAP_SHAPE_AGGREGATE
} from '@/constants'

export const LEGEND = {
  [MAP_SHAPE_AGGREGATE]: {
    label: 'Aggregate (Asserted distribution & Georeference)',
    background: 'bg-aggregate'
  },
  [ASSERTED_DISTRIBUTION]: {
    label: 'Asserted distribution',
    background: 'bg-asserted-distribution'
  },
  [GEOREFERENCE]: {
    label: 'Georeference',
    background: 'bg-georeference'
  },
  [COLLECTION_OBJECT]: {
    label: 'Collection object',
    background: 'bg-collection-object'
  },
  [TYPE_MATERIAL]: {
    label: 'Type material',
    background: 'bg-type-material'
  },
  [FIELD_OCCURRENCE]: {
    label: 'Field occurrence',
    background: 'bg-field-occurrence'
  }
}
