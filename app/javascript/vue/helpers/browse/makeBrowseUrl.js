import {
  ANATOMICAL_PART,
  COLLECTING_EVENT,
  COLLECTION_OBJECT,
  FIELD_OCCURRENCE,
  OTU,
  TAXON_NAME
} from '@/constants'
import { RouteNames } from '@/routes/routes'
import { ID_PARAM_FOR } from '@/components/radials/filter/constants/idParams'

const BROWSE_LINKS = {
  [COLLECTING_EVENT]: RouteNames.BrowseCollectingEvent,
  [COLLECTION_OBJECT]: RouteNames.BrowseCollectionObject,
  [FIELD_OCCURRENCE]: RouteNames.BrowseFieldOccurrence,
  [OTU]: RouteNames.BrowseOtu,
  [TAXON_NAME]: RouteNames.BrowseNomenclature
}

export function makeBrowseUrl({ id, type }) {
  // Filter Biological Association calls makeBrowseUrl, so this is needed.
  if (type == ANATOMICAL_PART) {
    // TODO: this should really point to the taxonomic_origin_object instead.
    return `/anatomical_parts/${id}`
  }

  const idParam = ID_PARAM_FOR[type]

  return `${BROWSE_LINKS[type]}?${idParam}=${id}`
}
