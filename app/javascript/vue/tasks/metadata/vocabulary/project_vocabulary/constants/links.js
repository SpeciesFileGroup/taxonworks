import {
  COLLECTING_EVENT,
  COLLECTION_OBJECT,
  DWC_OCCURRENCE,
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

  [DWC_OCCURRENCE]: {
    url: RouteNames.FilterDwcOccurrences,
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
