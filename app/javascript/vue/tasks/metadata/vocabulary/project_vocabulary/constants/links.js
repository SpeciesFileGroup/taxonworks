import {
  COLLECTING_EVENT,
  COLLECTION_OBJECT,
  OTU,
  SOURCE,
  TAXON_NAME
} from '@/constants'
import { RouteNames } from '@/routes/routes'

export const TASK = {
  [COLLECTING_EVENT]: {
    url: RouteNames.FilterCollectingEvents,
    arrayAttributes: []
  },

  [COLLECTION_OBJECT]: {
    url: RouteNames.FilterCollectionObjects,
    arrayAttributes: []
  },

  [SOURCE]: {
    url: RouteNames.FilterSources,
    arrayAttributes: []
  },

  [TAXON_NAME]: {
    url: RouteNames.FilterNomenclature,
    arrayAttributes: []
  },

  [OTU]: {
    url: RouteNames.FilterOtus,
    arrayAttributes: []
  }
}
