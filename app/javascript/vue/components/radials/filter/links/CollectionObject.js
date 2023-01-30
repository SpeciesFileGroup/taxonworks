// Update corresponding at SUBQUERIES in /lib/queries/query/filter.rb
import {
  FILTER_COLLECTING_EVENT,
  FILTER_EXTRACT,
  FILTER_OTU,
  FILTER_SOURCE,
  FILTER_TAXON_NAME
} from '../constants/filterLinks'

export const CollectionObject = {
  all: [FILTER_TAXON_NAME, FILTER_COLLECTING_EVENT, FILTER_OTU, FILTER_EXTRACT],
  ids: [
    FILTER_TAXON_NAME,
    FILTER_COLLECTING_EVENT,
    FILTER_OTU,
    FILTER_EXTRACT,
    FILTER_SOURCE
  ]
}
