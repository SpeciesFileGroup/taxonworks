import Vue from 'vue'
import Vuex from 'vuex'

const getters = require('./getters/getters')
const mutations = require('./mutations/mutations')
const actions = require('./actions/actions')

Vue.use(Vuex)

function makeInitialState () {
  return {
    settings: {
      saving: false,
    },
    collection_object: {
      id: undefined,
      total: undefined, 
      preparation_type_id: undefined, 
      repository_id: undefined,
      ranged_lot_category_id: undefined, 
      collecting_event_id: undefined,
      buffered_collecting_event: undefined, 
      buffered_determinations: undefined,
      buffered_other_labels: undefined, 
      deaccessioned_at: undefined, 
      deaccession_reason: undefined,
      contained_in: undefined,
      collecting_event_attributes: []
    },
    collection_event: {
      id: undefined,
      print_label: undefined, 
      print_label_number_to_print: undefined, 
      document_label: undefined,
      verbatim_label: undefined, 
      verbatim_locality: undefined, 
      verbatim_date: undefined, 
      verbatim_longitude: undefined, 
      verbatim_latitude: undefined,
      verbatim_geolocation_uncertainty: undefined, 
      verbatim_trip_identifier: undefined, 
      verbatim_collectors: undefined,
      verbatim_method: undefined, 
      verbatim_habitat: undefined, 
      verbatim_datum: undefined,
      verbatim_elevation: undefined,
      geographic_area_id: undefined, 
      minimum_elevation: undefined, 
      maximum_elevation: undefined,
      elevation_precision: undefined, 
      time_start_hour: undefined, 
      time_start_minute: undefined, 
      time_start_second: undefined,
      time_end_hour: undefined, 
      time_end_minute: undefined, 
      time_end_second: undefined, 
      start_date_day: undefined,
      start_date_month: undefined, 
      start_date_year: undefined, 
      end_date_day: undefined, 
      end_date_month: undefined,
      group: undefined, 
      member: undefined, 
      formation: undefined, 
      lithology: undefined, 
      max_ma: undefined, 
      min_ma: undefined,
      end_date_year: undefined, 
      field_notes: undefined, 
      roles_attributes: [],
      identifiers_attributes: []
    },
    type_material: {
      id: undefined,
      protonym_id: undefined,
      taxon: undefined,
      biological_object_id: undefined,
      type_type: undefined,
      roles_attributes: [],
      collection_object: undefined,
      origin_citation_attributes: undefined,
      type_designator_roles: []
    },
    depictions: []
  }
}

function newStore () {
  return new Vuex.Store({
    state: makeInitialState(),
    getters: getters.GetterFunctions,
    mutations: mutations.MutationFunctions,
    actions: actions.ActionFunctions
  })
}

module.exports = {
  newStore
}
