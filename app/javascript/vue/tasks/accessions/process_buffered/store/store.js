import Vue from 'vue'
import Vuex from 'vuex'

import { GetterFunctions } from './getters/getters'
import { MutationFunctions } from './mutations/mutations'
import { ActionFunctions } from './actions/actions'

Vue.use(Vuex)

function makeInitialState () {
  return {
    settings: {
      highlight: false,
      isSaving: false
    },
    collectingEvent: {
      verbatim_locality: undefined,
      geographic_area_id: undefined,
      verbatim_latitude: undefined,
      verbatim_longitude: undefined,
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
    inputSelection: undefined
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
