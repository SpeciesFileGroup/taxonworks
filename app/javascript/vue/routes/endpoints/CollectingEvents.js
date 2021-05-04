import baseCRUD, { annotations } from './base'
import AjaxCall from 'helpers/ajaxCall'

const controller = 'collecting_events'
const permitParams = {
  collecting_event: {
    id: Number,
    verbatim_label: String,
    print_label: String,
    print_label_number_to_print: String,
    document_label: String,
    verbatim_locality: String,
    verbatim_date: String,
    verbatim_longitude: String,
    verbatim_latitude: String,
    verbatim_geolocation_uncertainty: String,
    verbatim_trip_identifier: String,
    verbatim_collectors: String,
    verbatim_method: String,
    geographic_area_id: String,
    minimum_elevation: String,
    maximum_elevation: String,
    elevation_precision: String,
    time_start_hour: String,
    time_start_minute: String,
    time_start_second: String,
    time_end_hour: String,
    time_end_minute: String,
    time_end_second: String,
    start_date_day: String,
    start_date_month: String,
    start_date_year: String,
    end_date_day: String,
    end_date_month: String,
    group: String,
    member: String,
    formation: String,
    lithology: String,
    max_ma: String,
    min_ma: String,
    end_date_year: String,
    verbatim_habitat: String,
    field_notes: String,
    verbatim_datum: String,
    verbatim_elevation: String,
    roles_attributes: {
      id: Number,
      _destroy: Boolean,
      type: String,
      person_id: Number,
      position: Number,
      person_attributes: {
        last_name: String,
        first_name: String,
        suffix: String,
        prefix: String
      }
    },
    identifiers_attributes: {
      id: Number,
      namespace_id: Number,
      identifier: String,
      type: String,
      _destroy: Boolean
    },
    data_attributes_attributes: {
      id: Number,
      _destroy: Boolean,
      controlled_vocabulary_term_id: Number,
      type: String,
      attribute_subject_id: Number,
      attribute_subject_type: String,
      value: String
    }

  }
}

export const CollectingEvent = {
  ...baseCRUD(controller, permitParams),
  ...annotations(controller),

  attributes: () => AjaxCall('get', `/${controller}/attributes`),

  clone: (id) => AjaxCall('post', `/${controller}/${id}/clone`),

  navigation: (id) => AjaxCall('get', `/${controller}/${id}/navigation`),

  parseVerbatimLabel: (params) => AjaxCall('get', '/collecting_events/parse_verbatim_label', { params })
}
