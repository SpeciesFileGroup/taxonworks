import {
  COLLECTING_EVENT_PROPERTIES,
  COLLECTION_OBJECT_PROPERTIES,
  DWC_OCCURRENCE_PROPERTIES,
  REPOSITORY_PROPERTIES,
  TAXON_DETERMINATION_PROPERTIES,
  IDENTIFIER_PROPERTIES
} from '@/shared/Filter/constants'

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

  CollectingEvent: {
    properties: {
      collecting_event: COLLECTING_EVENT_PROPERTIES
    },
    includes: {}
  },

  LocateInCollection: {
    properties: {
      dwc_occurrence: [
        'catalogNumber',
        'preparations',
        'scientificName',
        'order',
        'superfamily',
        'family',
        'subfamily',
        'tribe',
        'subtribe'
      ]
    },
    includes: {}
  },

  TaxonNames: {
    properties: {
      collection_object: ['buffered_determinations'],
      taxon_determinations: ['otu_name'],
      dwc_occurrence: [
        'scientificName',
        'scientificNameAuthorship',
        'taxonRank',
        'phylum',
        'dwcClass',
        'order',
        'superfamily',
        'family',
        'subfamily',
        'tribe',
        'subtribe',
        'genus',
        'specificEpithet',
        'infraspecificEpithet',
        'previousIdentifications',
        'higherClassification',
        'typeStatus'
      ]
    },
    includes: {}
  },

  Place: {
    properties: {
      dwc_occurrence: [
        'country',
        'stateProvince',
        'county',
        'decimalLatitude',
        'decimalLongitude',
        'verbatimCoordinates',
        'coordinateUncertaintyInMeters',
        'geodeticDatum',
        'georeferenceProtocol',
        'georeferenceRemarks',
        'georeferenceSources',
        'georeferencedBy',
        'georeferenceDate',
        'verbatimSRS'
      ],
      collecting_event: [
        'verbatim_locality',
        'verbatim_latitude',
        'verbatim_longitude',
        'verbatim_geolocation_uncertainty',
        'minimum_elevation',
        'maximum_elevation'
      ]
    },
    includes: {}
  },

  Time: {
    properties: {
      collecting_event: [
        'verbatim_date',
        'start_date_year',
        'start_date_month',
        'start_date_day',
        'end_date_year',
        'end_date_month',
        'end_date_day',
        'time_start_hour',
        'time_start_minute',
        'time_start_second',
        'time_end_hour',
        'time_end_minute',
        'time_end_second',
        'max_ma',
        'min_ma'
      ],
      dwc_occurrence: []
    },
    includes: {}
  },

  Georeference: {
    properties: {
      dwc_occurrence: [
        'decimalLatitude',
        'decimalLongitude',
        'verbatimCoordinates',
        'coordinateUncertaintyInMeters',
        'geodeticDatum',
        'georeferenceProtocol',
        'georeferenceRemarks',
        'georeferenceSources',
        'georeferencedBy',
        'georeferenceDate',
        'verbatimSRS'
      ],
      collecting_event: [
        'verbatim_latititude',
        'verbatim_longitude',
        'verbatim_geolocation_uncertainty'
      ]
    },
    includes: {}
  },

  Verbatim: {
    properties: {
      collection_object: [
        'buffered_collecting_event',
        'buffered_determinations',
        'buffered_other_labels'
      ],
      collecting_event: [
        'verbatim_label',
        'verbatim_locality',
        'verbatim_longitude',
        'verbatim_latitude',
        'verbatim_geolocation_uncertainty',
        'verbatim_field_number',
        'verbatim_collectors',
        'verbatim_method',
        'verbatim_elevation',
        'verbatim_habitat',
        'verbatim_datum',
        'verbatim_date',
        'md5_of_verbatim_label'
      ]
    },
    includes: {}
  },

  Deaccessioned: {
    properties: {
      collection_object: [
        'accessioned_at',
        'deaccessioned_at',
        'deaccession_reason'
      ]
    },
    includes: {}
  },

  Paleo: {
    properties: {
      collection_object: [
        'group',
        'formation',
        'member',
        'lithology',
        'max_ma',
        'min_ma'
      ]
    },
    includes: {}
  },

  Labels: {
    properties: {
      collecting_event: ['verbatim_label', 'document_label', 'print_label']
    },
    includes: {}
  },

  People: {
    properties: {
      collection_object: ['buffered_determinations'],
      collecting_event: ['verbatim_collectors'],
      dwc_occurrence: [
        'recordedBy',
        'recordedByID',
        'identifiedBy',
        'identifiedByID',
        'scientificNameAuthorship',
        'georeferencedBy'
      ]
    },
    includes: {}
  },

  Identifiers: {
    properties: {
      dwc_occurrence: [
        'id',
        'catalogNumber',
        'otherCatalogNumbers',
        'occurrenceID',
        'fieldNumber'
      ],
      identifiers: IDENTIFIER_PROPERTIES
    },
    includes: {
      identifiers: true
    }
  },

  DataAttributes: {
    properties: {},
    includes: {
      data_attributes: true
    }
  }
}
