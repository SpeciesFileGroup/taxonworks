import {
  FILTER_COLLECTION_OBJECT,
  FILTER_FIELD_OCCURRENCE
} from '@/components/radials/filter/constants/filterLinks'
import { COLLECTION_OBJECT, FIELD_OCCURRENCE } from '@/constants'

const SLICES = {
  [COLLECTION_OBJECT]: FILTER_COLLECTION_OBJECT,
  [FIELD_OCCURRENCE]: FILTER_FIELD_OCCURRENCE
}

export function getExtendedFilter(objectType) {
  return {
    ...SLICES[objectType],
    flattenQuery: true
  }
}
