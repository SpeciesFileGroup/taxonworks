import { COLLECTING_EVENT_PROPERTIES } from '@/shared/Filter/constants'

export const LAYOUTS = {
  All: {
    properties: {
      collecting_event: [...COLLECTING_EVENT_PROPERTIES, 'identifiers', 'roles']
    },
    includes: {
      data_attributes: true
    }
  },

  DataAttributes: {
    properties: {},
    includes: {
      data_attributes: true
    }
  },

  Labels: {
    properties: {
      collecting_event: ['verbatim_label', 'print_label', 'document_label']
    },
    includes: {
      data_attributes: true
    }
  },

  Place: {
    properties: {
      collecting_event: [
        'cached_level0_geographic_name',
        'cached_level1_geographic_name',
        'cached_level2_geographic_name',
        'verbatim_locality',
        'verbatim_latitude',
        'verbatim_longitude',
        'verbatim_geolocation_uncertainty',
        'minimum_elevation',
        'maximum_elevation'
      ]
    },
    includes: {
      data_attributes: true
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
      ]
    },
    includes: {
      data_attributes: true
    }
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
    includes: {
      data_attributes: true
    }
  }
}
