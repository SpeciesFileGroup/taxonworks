import {
  ASSERTED_DISTRIBUTION,
  BIOLOGICAL_ASSOCIATION,
  COLLECTING_EVENT,
  COLLECTION_OBJECT,
  CONTENT,
  DESCRIPTOR,
  EXTRACT,
  IMAGE,
  OBSERVATION,
  OTU,
  PEOPLE,
  SOURCE,
  TAXON_NAME
} from 'constants/index.js'

export const FILTER_LINKS = {
  [COLLECTION_OBJECT]: {
    label: 'Collection objects',
    link: '/tasks/collection_objects/filter'
  },
  [COLLECTING_EVENT]: {
    label: 'Collecting events',
    link: '/tasks/collecting_events/filter'
  },
  [EXTRACT]: {
    label: 'Extracts',
    link: '/tasks/extracts/filter'
  },
  [OTU]: {
    label: 'OTUs',
    link: '/tasks/otus/filter'
  },
  [TAXON_NAME]: {
    label: 'Nomenclature',
    link: '/tasks/taxon_names/filter'
  },
  [SOURCE]: {
    label: 'Sources',
    link: '/tasks/sources/filter'
  },
  [ASSERTED_DISTRIBUTION]: {
    label: 'Asserted distributions',
    link: '/tasks/asserted_distributions/filter'
  },
  [BIOLOGICAL_ASSOCIATION]: {
    label: 'Biological associations',
    link: '/tasks/biological_associations/filter'
  },
  [IMAGE]: {
    label: 'Images',
    link: '/tasks/images/filter'
  },
  [PEOPLE]: {
    label: 'People',
    link: '/tasks/people/filter'
  },
  [DESCRIPTOR]: {
    label: 'Descriptors',
    link: '/tasks/descriptors/filter'
  },
  [CONTENT]: {
    label: 'Contents',
    link: '/tasks/content/filter'
  },
  [OBSERVATION]: {
    label: 'Observations',
    link: '/tasks/observations/filter'
  }
}
