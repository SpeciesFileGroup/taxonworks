import {
  COLLECTING_EVENT_PROPERTIES,
  FIELD_OCCURRENCE_PROPERTIES,
  TAXON_DETERMINATION_PROPERTIES,
  IDENTIFIER_PROPERTIES,
  DWC_OCCURRENCE_PROPERTIES
} from '@/shared/Filter/constants'

export const LAYOUTS = {
  All: {
    properties: {
      field_occurrence: FIELD_OCCURRENCE_PROPERTIES,
      collecting_event: COLLECTING_EVENT_PROPERTIES,
      taxon_determinations: TAXON_DETERMINATION_PROPERTIES,
      dwc_occurrence: DWC_OCCURRENCE_PROPERTIES,
      identifiers: IDENTIFIER_PROPERTIES,
      data_attributes: {
        show: true
      }
    }
  },

  DwC: {
    properties: {
      dwc_occurrence: DWC_OCCURRENCE_PROPERTIES,
      data_attributes: {
        show: true
      }
    }
  },

  TaxonWorks: {
    properties: {
      field_occurrence: FIELD_OCCURRENCE_PROPERTIES,
      collecting_event: COLLECTING_EVENT_PROPERTIES,
      taxon_determinations: TAXON_DETERMINATION_PROPERTIES,
      identifiers: IDENTIFIER_PROPERTIES,
      data_attributes: {
        show: true
      }
    }
  },

  CollectingEvent: {
    properties: {
      collecting_event: COLLECTING_EVENT_PROPERTIES
    }
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
    }
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
    }
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
    }
  },

  DataAttributes: {
    properties: {
      data_attributes: {
        show: true
      }
    }
  }
}
