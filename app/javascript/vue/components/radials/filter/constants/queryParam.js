import {
  ASSERTED_DISTRIBUTION,
  BIOLOGICAL_ASSOCIATION,
  COLLECTING_EVENT,
  COLLECTION_OBJECT,
  CONTENT,
  DESCRIPTOR,
  DWC_OCCURRENCE,
  EXTRACT,
  FIELD_OCCURRENCE,
  IMAGE,
  LOAN,
  OBSERVATION,
  OTU,
  PEOPLE,
  SOUND,
  SOURCE,
  TAXON_NAME
} from '@/constants/index.js'

export const QUERY_PARAM = {
  [ASSERTED_DISTRIBUTION]: 'asserted_distribution_query',
  [BIOLOGICAL_ASSOCIATION]: 'biological_association_query',
  [COLLECTING_EVENT]: 'collecting_event_query',
  [COLLECTION_OBJECT]: 'collection_object_query',
  [CONTENT]: 'content_query',
  [DESCRIPTOR]: 'descriptor_query',
  [DWC_OCCURRENCE]: 'dwc_occurrence_query',
  [EXTRACT]: 'extract_query',
  [FIELD_OCCURRENCE]: 'field_occurrence_query',
  [IMAGE]: 'image_query',
  [LOAN]: 'loan_query',
  [OBSERVATION]: 'observation_query',
  [OTU]: 'otu_query',
  [PEOPLE]: 'people_query',
  [SOUND]: 'sound_query',
  [SOURCE]: 'source_query',
  [TAXON_NAME]: 'taxon_name_query'
}
