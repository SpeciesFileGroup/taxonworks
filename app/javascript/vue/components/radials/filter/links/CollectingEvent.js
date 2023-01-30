// Update corresponding at SUBQUERIES in /lib/queries/query/filter.rb
import {
  FILTER_OTU,
  FILTER_TAXON_NAME,
  FILTER_COLLECTION_OBJECT
} from '../constants/filterLinks'

export const CollectingEvent = {
  all: [FILTER_OTU, FILTER_TAXON_NAME, FILTER_COLLECTION_OBJECT],
  ids: [FILTER_OTU]
}
