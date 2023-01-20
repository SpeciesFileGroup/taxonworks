// Update corresponding at SUBQUERIES in /lib/queries/query/filter.rb
import { FILTER_LINKS } from '../constants/filterLinks'
import {
  COLLECTING_EVENT,
  TAXON_NAME,
  OTU,
  EXTRACT,
  SOURCE
} from 'constants/index.js'

export const CollectionObject = {
  all: [
    FILTER_LINKS[TAXON_NAME],
    FILTER_LINKS[COLLECTING_EVENT],
    FILTER_LINKS[OTU],
    FILTER_LINKS[EXTRACT]
  ],
  ids: [
    FILTER_LINKS[TAXON_NAME],
    FILTER_LINKS[COLLECTING_EVENT],
    FILTER_LINKS[OTU],
    FILTER_LINKS[EXTRACT],
    FILTER_LINKS[SOURCE]
  ]
}
