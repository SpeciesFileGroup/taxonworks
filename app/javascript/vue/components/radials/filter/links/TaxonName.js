import { FILTER_LINKS } from '../constants/filterLinks'
import {
  OTU,
  COLLECTION_OBJECT,
  SOURCE,
  COLLECTING_EVENT
} from 'constants/index.js'

export const TaxonName = {
  all: [
    FILTER_LINKS[COLLECTING_EVENT],
    FILTER_LINKS[SOURCE],
    FILTER_LINKS[OTU],
    FILTER_LINKS[COLLECTION_OBJECT]
  ],
  ids: []
}
