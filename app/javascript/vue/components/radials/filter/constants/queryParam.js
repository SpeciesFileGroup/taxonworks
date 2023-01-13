import {
  ASSERTED_DISTRIBUTION,
  BIOLOGICAL_ASSOCIATION,
  COLLECTING_EVENT,
  COLLECTION_OBJECT,
  EXTRACT,
  IMAGE,
  OTU,
  PEOPLE,
  SOURCE,
  TAXON_NAME,
} from 'constants/index.js'

export const QUERY_PARAM = {
  [IMAGE]: 'image_query',
  [ASSERTED_DISTRIBUTION]: 'asserted_distribution_query',
  [BIOLOGICAL_ASSOCIATION]: 'biological_association_query',
  [COLLECTING_EVENT]: 'collecting_event_query,',
  [COLLECTION_OBJECT]: 'collection_object_query',
  [EXTRACT]: 'extract_query,',
  [OTU]: 'otu_query',
  [SOURCE]: 'source_query',
  [TAXON_NAME]: 'taxon_name_query'
}