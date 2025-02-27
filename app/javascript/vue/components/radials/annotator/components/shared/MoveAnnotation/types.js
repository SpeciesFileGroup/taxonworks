import {
  OTU,
  COLLECTING_EVENT,
  COLLECTION_OBJECT,
  TAXON_NAME,
  PERSON,
  CITATION,
  DEPICTION
} from '@/constants'

export const OBJECT_TYPES = {
  [OTU]: {
    label: 'Otu',
    url: '/otus/autocomplete',
    annotations: [CITATION, DEPICTION]
  },
  [COLLECTING_EVENT]: {
    label: 'Collecting event',
    url: '/collecting_events/autocomplete',
    annotations: [CITATION, DEPICTION]
  },
  [COLLECTION_OBJECT]: {
    label: 'Collection object',
    url: '/collection_objects/autocomplete',
    annotations: [CITATION, DEPICTION]
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
