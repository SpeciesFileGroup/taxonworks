import {
  ASSERTED_DISTRIBUTION,
  BIOLOGICAL_ASSOCIATION,
  BIOLOGICAL_ASSOCIATIONS_GRAPH,
  COLLECTING_EVENT,
  COLLECTION_OBJECT,
  COMBINATION,
  CONTAINER,
  CONTENT,
  CONTROLLED_VOCABULARY_TERM,
  DATA_ATTRIBUTE,
  DEPICTION,
  DESCRIPTOR,
  EXTRACT,
  FIELD_OCCURRENCE,
  GEOREFERENCE,
  IMAGE,
  LEAD,
  LOAN,
  OBSERVATION,
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
    autocomplete: '/collecting_events/autocomplete'
  },
  [COLLECTION_OBJECT]: {
    autocomplete: '/collection_objects/autocomplete'
  },
  [COMBINATION]: {
    autocomplete: '/combinations/autocomplete'
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
  [DATA_ATTRIBUTE]: {
    autocomplete: '/data_attributes/autocomplete'
  },
  [DEPICTION]: {
    autocomplete: '/depictions/autocomplete'
  },
  [DESCRIPTOR]: {
    autocomplete: '/descriptors/autocomplete'
  },
  [EXTRACT]: {
    autocomplete: '/extracts/autocomplete'
  },
  [FIELD_OCCURRENCE]: {
    autocomplete: '/field_occurrences/autocomplete'
  },
  [GEOREFERENCE]: {
    autocomplete: '/georeferences/autocomplete'
  },
  [IMAGE]: {
    autocomplete: '/images/autocomplete'
  },
  [LEAD]: {
    autocomplete: '/leads/autocomplete'
  },
  [LOAN]: {
    autocomplete: '/loans/autocomplete'
  },
  [OBSERVATION]: {
    autocomplete: '/observations/autocomplete'
  },
  [OTU]: {
    autocomplete: '/otus/autocomplete'
  },
  [PEOPLE]: {
    autocomplete: '/people/autocomplete'
  },
  [SOURCE]: {
    autocomplete: '/sources/autocomplete'
  },
  [TAXON_DETERMINATION]: {
    autocomplete: '/sources/autocomplete'
  },
  [TAXON_NAME]: {
    autocomplete: '/taxon_names/autocomplete'
  },
  [TYPE_MATERIAL]: {
    autocomplete: '/type_materials/autocomplete'
  }
}
