// Update corresponding at SUBQUERIES in /lib/queries/query/filter.rb
import { FILTER_LINKS } from '../constants/filterLinks'
import { COLLECTION_OBJECT, TAXON_NAME, OTU } from 'constants/index.js'

export const CollectingEvent = {
  all: [
    FILTER_LINKS[OTU],
    FILTER_LINKS[TAXON_NAME],
    FILTER_LINKS[COLLECTION_OBJECT]
  ],
  ids: [
    FILTER_LINKS[OTU],
  ]
}
