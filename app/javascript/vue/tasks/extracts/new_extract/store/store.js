import Vue from 'vue'
import Vuex from 'vuex'

import { ActionFunctions } from '../store/actions/actions'
import { GetterFunctions } from '../store/getters/getters'
import { MutationFunctions } from '../store/mutations/mutations'

Vue.use(Vuex)

const makeInitialState = () => {
  return {
    settings: {
      lock: {
        date: false,
        lock: false,
        protocol: false
      },
      sortable: false
    },
    extract: {
      quantity_value: undefined,
      quantity_unit: undefined,
      concentration_value: undefined,
      concentration_unit: undefined,
      verbatim_anatomical_origin: undefined,
      year_made: undefined,
      month_made: undefined,
      day_made: undefined
    },
    softValidation: []
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
