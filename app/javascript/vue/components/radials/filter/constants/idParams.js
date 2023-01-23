import {
  ASSERTED_DISTRIBUTION,
  BIOLOGICAL_ASSOCIATION,
  COLLECTING_EVENT,
  COLLECTION_OBJECT,
  DESCRIPTOR,
  EXTRACT,
  IMAGE,
  LOAN,
  OTU,
  PEOPLE,
  SOURCE,
  TAXON_NAME,
  OBSERVATION,
  CONTENT
} from 'constants/index.js'

export const ID_PARAM_FOR = {
  [OTU]: 'otu_id',
  [PEOPLE]: 'person_id',
  [SOURCE]: 'source_id',
  [COLLECTING_EVENT]: 'collecting_event_id',
  [ASSERTED_DISTRIBUTION]: 'asserted_distribution_id',
  [EXTRACT]: 'extract_id',
  [COLLECTION_OBJECT]: 'collection_object_id',
  [BIOLOGICAL_ASSOCIATION]: 'biological_association_id',
  [DESCRIPTOR]: 'descriptor_id',
  [IMAGE]: 'image_id',
  [TAXON_NAME]: 'taxon_name_id',
  [LOAN]: 'loan_id',
  [OBSERVATION]: 'observation_id',
  [CONTENT]: 'content_id'
}
