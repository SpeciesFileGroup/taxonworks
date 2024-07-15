import {
  ASSERTED_DISTRIBUTION,
  BIOLOGICAL_ASSOCIATION,
  BIOLOGICAL_ASSOCIATIONS_GRAPH,
  COLLECTING_EVENT,
  COLLECTION_OBJECT,
  CONTAINER,
  CONTENT,
  CONTROLLED_VOCABULARY_TERM,
  DEPICTION,
  DESCRIPTOR,
  EXTRACT,
  FIELD_OCCURRENCE,
  GEOREFERENCE,
  IMAGE,
  LOAN,
  OBSERVATION,
  OBSERVATION_MATRIX,
  OTU,
  PEOPLE,
  SOURCE,
  TAXON_DETERMINATION,
  TAXON_NAME,
  TYPE_MATERIAL
} from '@/constants'

export const TYPE_LINKS = {
  [ASSERTED_DISTRIBUTION]: {
    autocomplete: '/asserted_distributions/autocomplete'
  },
  [BIOLOGICAL_ASSOCIATION]: {
    autocomplete: '/biological_associations/autocomplete'
  },
  [BIOLOGICAL_ASSOCIATIONS_GRAPH]: {
    autocomplete: '/biological_associations_graphs/autocomplete'
  },
  [COLLECTING_EVENT]: {
    autocomplete: '/collecting_events/autocomplete',
    smartSelector: 'collecting_events'
  },
  [COLLECTION_OBJECT]: {
    autocomplete: '/collection_objects/autocomplete',
    radialObject: true,
    smartSelector: 'collection_objects'
  },
  [CONTAINER]: {
    autocomplete: '/containers/autocomplete'
  },
  [CONTENT]: {
    autocomplete: '/contents/autocomplete'
  },
  [CONTROLLED_VOCABULARY_TERM]: {
    autocomplete: '/controlled_vocabulary_terms/autocomplete'
  },
  [DEPICTION]: {
    autocomplete: '/depictions/autocomplete'
  },
  [DESCRIPTOR]: {
    autocomplete: '/descriptors/autocomplete'
  },
  [EXTRACT]: {
    autocomplete: '/extracts/autocomplete',
    smartSelector: 'extracts'
  },
  [FIELD_OCCURRENCE]: {
    autocomplete: '/field_occurrences/autocomplete'
  },
  [GEOREFERENCE]: {
    autocomplete: '/georeferences/autocomplete'
  },
  [IMAGE]: {
    autocomplete: '/images/autocomplete',
    radialObject: true
  },
  [LOAN]: {
    autocomplete: '/loans/autocomplete'
  },
  [OBSERVATION]: {
    autocomplete: '/observations/autocomplete'
  },
  [OBSERVATION_MATRIX]: {
    autocomplete: '/observation_matrices/autocomplete'
  },
  [OTU]: {
    autocomplete: '/otus/autocomplete',
    radialObject: true
  },
  [SOURCE]: {
    autocomplete: '/sources/autocomplete',
    radialObject: true,
    smartSelector: 'sources'
  },
  [TAXON_DETERMINATION]: {
    autocomplete: '/sources/autocomplete'
  },
  [TAXON_NAME]: {
    autocomplete: '/taxon_names/autocomplete',
    smartSelector: 'taxon_names'
  },
  [TYPE_MATERIAL]: {
    autocomplete: '/type_materials/autocomplete'
  }
}
