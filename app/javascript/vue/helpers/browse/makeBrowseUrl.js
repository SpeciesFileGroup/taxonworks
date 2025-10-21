import {
  ANATOMICAL_PART,
  COLLECTING_EVENT,
  COLLECTION_OBJECT,
  EXTRACT,
  FIELD_OCCURRENCE,
  OTU,
  SEQUENCE,
  SOUND,
  TAXON_NAME
} from '@/constants'
import { RouteNames } from '@/routes/routes'
import { ID_PARAM_FOR } from '@/components/radials/filter/constants/idParams'

const BROWSE_LINKS = {
  [ANATOMICAL_PART]: '/anatomical_parts/',
  [COLLECTING_EVENT]: RouteNames.BrowseCollectingEvent,
  [COLLECTION_OBJECT]: RouteNames.BrowseCollectionObject,
  [EXTRACT]: '/extracts/',
  [FIELD_OCCURRENCE]: RouteNames.BrowseFieldOccurrence,
  [OTU]: RouteNames.BrowseOtu,
  [SEQUENCE]: '/sequences/',
  [SOUND]: RouteNames.BrowseSound,
  [TAXON_NAME]: RouteNames.BrowseNomenclature
}

export function makeBrowseUrl({ id, type }) {
  if (type == ANATOMICAL_PART || type == EXTRACT || type == SEQUENCE) {
    return `${BROWSE_LINKS[type]}${id}`
  }

  const idParam = ID_PARAM_FOR[type]

  return `${BROWSE_LINKS[type]}?${idParam}=${id}`
}
