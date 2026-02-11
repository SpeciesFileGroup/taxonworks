import {
  FIELD_OCCURRENCE,
  TYPE_MATERIAL,
  COLLECTION_OBJECT,
  GEOREFERENCE,
  ASSERTED_DISTRIBUTION,
  MAP_SHAPE_AGGREGATE,
  MAP_SHAPE_ASSERTED_DISTRIBUTION_ABSENT
} from '@/constants'

export const MAP_LEGEND = {
  [MAP_SHAPE_ASSERTED_DISTRIBUTION_ABSENT]: {
    label: 'Asserted absent',
    background: 'bg-asserted-distribution-absent'
  },
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
    label: 'Primary type',
    background: 'bg-type-material'
  },
  [FIELD_OCCURRENCE]: {
    label: 'Field occurrence',
    background: 'bg-field-occurrence'
  }
}
