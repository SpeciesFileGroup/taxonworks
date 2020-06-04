import Vue from 'vue'
import Vuex from 'vuex'

import { GetterFunctions } from './getters/getters'
import { MutationFunctions } from './mutations/mutations'
import { ActionFunctions } from './actions/actions'

Vue.use(Vuex)

function makeInitialState () {
  return {
    settings: {
      saving: false,
      loading: false,
      increment: false,
      lastSave: 0,
      lastChange: 0,
      saveIdentifier: true,
      isLocked: false,
      locked: {
        biocuration: false,
        identifier: false,
        collecting_event: false,
        collection_object: {
          buffered_determinations: false,
          buffered_collecting_event: false,
          buffered_other_labels: false,
          repository_id: false,
          preparation_type_id: false
        },
        taxon_determination: {
          otu_id: false,
          year_made: false,
          month_made: false,
          day_made: false,
          dates: false,
          roles_attributes: false
        },
        biological_association: {
          relationship: false,
          related: false
        }
      },
      sortable: false
    },
    taxon_determination: {
      biological_collection_object_id: undefined,
      otu_id: undefined,
      year_made: undefined,
      month_made: undefined,
      day_made: undefined,
      roles_attributes: [],
    },
    identifier: {
      id: undefined,
      namespace_id: undefined,
      type: 'Identifier::Local::CatalogNumber',
      identifier_object_id: undefined,
      identifier_object_type: 'CollectionObject',
      identifier: undefined
    },
    collectingEventIdentifier: {
      id: undefined,
      namespace_id: undefined,
      type: 'Identifier::Local::TripCode',
      identifier: undefined
    },
    collection_object: {
      id: undefined,
      global_id: undefined,
      total: 1,
      preparation_type_id: null,
      repository_id: undefined,
      ranged_lot_category_id: undefined,
      collecting_event_id: undefined,
      buffered_collecting_event: undefined,
      buffered_determinations: undefined,
      buffered_other_labels: undefined,
      deaccessioned_at: undefined,
      deaccession_reason: undefined,
      contained_in: undefined
    },
    collection_event: {
      id: undefined,
      global_id: undefined,
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
      end_date_year: undefined,
      group: undefined, 
      member: undefined, 
      formation: undefined, 
      lithology: undefined, 
      max_ma: undefined, 
      min_ma: undefined,
      field_notes: undefined, 
      roles_attributes: [],
      identifiers_attributes: []
    },
    type_material: {
      id: undefined,
      global_id: undefined,
      protonym_id: undefined,
      taxon: undefined,
      collection_object_id: undefined,
      type_type: undefined,
      collection_object: undefined,
      origin_citation_attributes: undefined
    },
    label: {
      id: undefined,
      text: undefined,
      total: undefined,
      label_object_id: undefined, 
      label_object_type: "CollectingEvent"
    },
    geographicArea: undefined,
    tmpData: {
      otu: undefined
    },
    subsequentialUses: 0,
    identifiers: [],
    materialTypes: [],
    determinations: [],
    preferences: {},
    project_preferences: undefined,
    container: undefined,
    containerItems: [],
    collection_objects: [],
    depictions: [],
    COTypes: [],
    biocurations: [],
    preparation_type_id: undefined,
    taxon_determinations: [],
    namespaceSelected: ''
  }
}

function newStore () {
  return new Vuex.Store({
    state: makeInitialState(),
    getters: GetterFunctions,
    mutations: MutationFunctions,
    actions: ActionFunctions
  })
}

export {
  newStore,
  makeInitialState
}
