// Update corresponding at SUBQUERIES in /lib/queries/query/filter.rb
import {
  FILTER_OTU,
  FILTER_TAXON_NAME,
  FILTER_COLLECTION_OBJECT,
  FILTER_BIOLOGICAL_ASSOCIATION
} from '../constants/filterLinks'

export const CollectingEvent = {
  all: [
    FILTER_OTU,
    FILTER_TAXON_NAME,
    FILTER_COLLECTION_OBJECT,
    FILTER_BIOLOGICAL_ASSOCIATION,
  ],
  ids: [FILTER_OTU]
}
