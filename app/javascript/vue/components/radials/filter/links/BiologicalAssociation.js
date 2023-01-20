import { FILTER_LINKS } from '../constants/filterLinks'
import {
  COLLECTION_OBJECT,
  COLLECTING_EVENT,
  SOURCE,
  TAXON_NAME,
  OTU
} from 'constants/index.js'

export const BiologicalAssociation = {
  all: [
    FILTER_LINKS[COLLECTION_OBJECT],
    FILTER_LINKS[COLLECTING_EVENT],
    FILTER_LINKS[OTU],
    FILTER_LINKS[TAXON_NAME],
    FILTER_LINKS[SOURCE]
  ],
  ids: []
}
