import {
  AssertedDistribution,
  BiologicalAssociation,
  CollectionObject,
  CollectingEvent,
  Descriptor,
  Extract,
  Image,
  Loan,
  Observation,
  Otu,
  People,
  Sound,
  Source,
  TaxonName
} from '@/routes/endpoints'
import {
  ASSERTED_DISTRIBUTION,
  BIOLOGICAL_ASSOCIATION,
  COLLECTING_EVENT,
  COLLECTION_OBJECT,
  DESCRIPTOR,
  EXTRACT,
  IMAGE,
  LOAN,
  OBSERVATION,
  OTU,
  PEOPLE,
  SOUND,
  SOURCE,
  TAXON_NAME
} from '@/constants'
import { FILTER_ROUTES } from '@/routes/routes'
import { QUERY_PARAM } from '@/components/radials/filter/constants/queryParam.js'

export const QUERY_PARAMETER = {
  [QUERY_PARAM[ASSERTED_DISTRIBUTION]]: {
    model: ASSERTED_DISTRIBUTION,
    service: AssertedDistribution,
    filterUrl: FILTER_ROUTES[ASSERTED_DISTRIBUTION]
  },

  [QUERY_PARAM[BIOLOGICAL_ASSOCIATION]]: {
    model: BIOLOGICAL_ASSOCIATION,
    service: BiologicalAssociation,
    filterUrl: FILTER_ROUTES[BIOLOGICAL_ASSOCIATION]
  },

  [QUERY_PARAM[COLLECTING_EVENT]]: {
    model: COLLECTING_EVENT,
    service: CollectingEvent,
    filterUrl: FILTER_ROUTES[COLLECTING_EVENT]
  },

  [QUERY_PARAM[COLLECTION_OBJECT]]: {
    model: COLLECTION_OBJECT,
    service: CollectionObject,
    filterUrl: FILTER_ROUTES[COLLECTION_OBJECT]
  },

  [QUERY_PARAM[DESCRIPTOR]]: {
    model: DESCRIPTOR,
    service: Descriptor,
    filterUrl: FILTER_ROUTES[DESCRIPTOR]
  },

  [QUERY_PARAM[EXTRACT]]: {
    model: EXTRACT,
    service: Extract,
    filterUrl: FILTER_ROUTES[EXTRACT]
  },

  [QUERY_PARAM[IMAGE]]: {
    model: IMAGE,
    service: Image,
    filterUrl: FILTER_ROUTES[IMAGE]
  },

  [QUERY_PARAM[LOAN]]: {
    model: LOAN,
    service: Loan,
    filterUrl: FILTER_ROUTES[LOAN]
  },

  [QUERY_PARAM[OBSERVATION]]: {
    model: OBSERVATION,
    service: Observation,
    filterUrl: FILTER_ROUTES[OBSERVATION]
  },

  [QUERY_PARAM[OTU]]: {
    model: OTU,
    service: Otu,
    filterUrl: FILTER_ROUTES[OTU]
  },

  [QUERY_PARAM[PEOPLE]]: {
    model: PEOPLE,
    service: People,
    filterUrl: FILTER_ROUTES[PEOPLE]
  },

  [QUERY_PARAM[SOUND]]: {
    model: SOUND,
    service: Sound,
    filterUrl: FILTER_ROUTES[SOUND]
  },

  [QUERY_PARAM[SOURCE]]: {
    model: SOURCE,
    service: Source,
    filterUrl: FILTER_ROUTES[SOURCE]
  },

  [QUERY_PARAM[TAXON_NAME]]: {
    model: TAXON_NAME,
    service: TaxonName,
    filterUrl: FILTER_ROUTES[TAXON_NAME]
  }
}
