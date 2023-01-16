// Update corresponding at SUBQUERIES in /lib/queries/query/filter.rb
import { FILTER_LINKS } from '../constants/filterLinks'
import {
  COLLECTING_EVENT,
  TAXON_NAME,
  OTU,
  EXTRACT
} from 'constants/index.js'

export const CollectionObject = [
  FILTER_LINKS[TAXON_NAME],
  FILTER_LINKS[COLLECTING_EVENT],
  FILTER_LINKS[OTU],
  FILTER_LINKS[EXTRACT]
]
