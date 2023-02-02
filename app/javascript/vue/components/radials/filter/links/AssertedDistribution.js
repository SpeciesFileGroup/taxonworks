import {
  FILTER_OTU,
  FILTER_SOURCE,
  FILTER_TAXON_NAME,
} from '../constants/filterLinks'

export const AssertedDistribution = {
  all: [
    FILTER_SOURCE,
    FILTER_OTU,
    FILTER_TAXON_NAME,
  ],
  
  ids: [
    FILTER_OTU,
    FILTER_TAXON_NAME,
  ]
}
