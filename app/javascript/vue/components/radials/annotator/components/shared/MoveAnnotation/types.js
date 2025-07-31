import {
  OTU,
  COLLECTING_EVENT,
  COLLECTION_OBJECT,
  FIELD_OCCURRENCE,
  TAXON_NAME,
  PERSON,
  CITATION,
  DEPICTION,
  CONVEYANCE
} from '@/constants'

export const OBJECT_TYPES = {
  [OTU]: {
    label: 'Otu',
    url: '/otus/autocomplete',
    annotations: [CITATION, DEPICTION, CONVEYANCE]
  },
  [COLLECTING_EVENT]: {
    label: 'Collecting event',
    url: '/collecting_events/autocomplete',
    annotations: [CITATION, DEPICTION, CONVEYANCE]
  },
  [COLLECTION_OBJECT]: {
    label: 'Collection object',
    url: '/collection_objects/autocomplete',
    annotations: [CITATION, DEPICTION, CONVEYANCE]
  },
  [FIELD_OCCURRENCE]: {
    label: 'Field occurrence',
    url: '/field_occurrences/autocomplete',
    annotations: [CITATION, DEPICTION, CONVEYANCE]
  },
  [TAXON_NAME]: {
    label: 'Taxon name',
    url: '/taxon_names/autocomplete',
    annotations: [CITATION, DEPICTION]
  },
  [PERSON]: {
    label: 'Person',
    url: '/people/autocomplete',
    annotations: [DEPICTION]
  }
}
