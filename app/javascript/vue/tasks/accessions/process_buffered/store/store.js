import Vue from 'vue'
import Vuex from 'vuex'

import { GetterFunctions } from './getters/getters'
import { MutationFunctions } from './mutations/mutations'
import { ActionFunctions } from './actions/actions'

Vue.use(Vuex)

function makeInitialState () {
  return {
    settings: {
      highlight: true,
      isSaving: false,
      lastSave: undefined,
      lastChange: undefined
    },
    collectingEvent: {
      geographic_area_id: undefined,
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
      start_date_day: undefined,
      start_date_month: undefined,
      start_date_year: undefined,
      end_date_day: undefined,
      end_date_month: undefined,
      end_date_year: undefined
    },
    collectionObject: {
      id: undefined,
      buffered_collecting_event: undefined
    },
    nearbyCO: undefined,
    sqedDepictions: [],
    inputSelection: undefined,
    typeSelected: undefined
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
  newStore
}
