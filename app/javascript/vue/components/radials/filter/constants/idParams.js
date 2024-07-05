import {
  ASSERTED_DISTRIBUTION,
  BIOLOGICAL_ASSOCIATION,
  COLLECTING_EVENT,
  COLLECTION_OBJECT,
  CONTENT,
  DESCRIPTOR,
  DWC_OCCURRENCE,
  EXTRACT,
  IMAGE,
  LOAN,
  OBSERVATION,
  OTU,
  PEOPLE,
  SOURCE,
  TAXON_NAME
} from '@/constants/index.js'

export const ID_PARAM_FOR = {
  [ASSERTED_DISTRIBUTION]: 'asserted_distribution_id',
  [BIOLOGICAL_ASSOCIATION]: 'biological_association_id',
  [COLLECTING_EVENT]: 'collecting_event_id',
  [COLLECTION_OBJECT]: 'collection_object_id',
  [CONTENT]: 'content_id',
  [DESCRIPTOR]: 'descriptor_id',
  [DWC_OCCURRENCE]: 'dwc_occurrence_id',
  [EXTRACT]: 'extract_id',
  [IMAGE]: 'image_id',
  [LOAN]: 'loan_id',
  [OBSERVATION]: 'observation_id',
  [OTU]: 'otu_id',
  [PEOPLE]: 'person_id',
  [SOURCE]: 'source_id',
  [TAXON_NAME]: 'taxon_name_id'
}
