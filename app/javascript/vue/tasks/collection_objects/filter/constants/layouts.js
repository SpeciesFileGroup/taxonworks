import {
  COLLECTING_EVENT_PROPERTIES,
  COLLECTION_OBJECT_PROPERTIES,
  DWC_OCCURRENCE_PROPERTIES,
  REPOSITORY_PROPERTIES,
  TAXON_DETERMINATION_PROPERTIES,
  IDENTIFIER_PROPERTIES
} from 'shared/Filter/constants'

export const LAYOUTS = {
  All: {
    properties: {
      collection_object: COLLECTION_OBJECT_PROPERTIES,
      current_repository: REPOSITORY_PROPERTIES,
      repository: REPOSITORY_PROPERTIES,
      collecting_event: COLLECTING_EVENT_PROPERTIES,
      taxon_determinations: TAXON_DETERMINATION_PROPERTIES,
      dwc_occurrence: DWC_OCCURRENCE_PROPERTIES,
      identifiers: IDENTIFIER_PROPERTIES
    },
    includes: {
      data_attributes: true
    }
  },

  DwC: {
    properties: {
      dwc_occurrence: DWC_OCCURRENCE_PROPERTIES
    },
    includes: {
      data_attributes: false
    }
  },

  TaxonWorks: {
    properties: {
      collection_object: COLLECTION_OBJECT_PROPERTIES,
      current_repository: REPOSITORY_PROPERTIES,
      repository: REPOSITORY_PROPERTIES,
      collecting_event: COLLECTING_EVENT_PROPERTIES,
      taxon_determinations: TAXON_DETERMINATION_PROPERTIES,
      identifiers: IDENTIFIER_PROPERTIES
    },
    includes: {
      data_attributes: true
    }
  },

  Custom: {
    properties: {
      collection_object: COLLECTION_OBJECT_PROPERTIES,
      current_repository: REPOSITORY_PROPERTIES,
      repository: REPOSITORY_PROPERTIES,
      collecting_event: COLLECTING_EVENT_PROPERTIES,
      taxon_determinations: TAXON_DETERMINATION_PROPERTIES,
      dwc_occurrence: DWC_OCCURRENCE_PROPERTIES,
      identifiers: IDENTIFIER_PROPERTIES
    },
    includes: {
      data_attributes: true
    }
  }
}
