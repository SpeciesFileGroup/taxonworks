import Vue from 'vue'
import Vuex from 'vuex'

import { GetterFunctions } from './getters/getters'
import { MutationFunctions } from './mutations/mutations'
import { ActionFunctions } from './actions/actions'

Vue.use(Vuex)

function makeInitialState () {
  return {
    settings: {
      gridLayout: 'layout-mode-1',
      isLoading: false,
      isRefreshing: false,
      refreshOnlyTaxa: false,
      rowFilter: true
    },
    observationMatrix: undefined,
    observationMatrixDescriptors: [],
    descriptorsFilter: {},
    row_filter: [],
    filters: {
      error_tolerance: undefined,
      identified_to_rank: undefined,
      sorting: undefined,
      language_id: undefined,
      eliminate_unknown: undefined,
      otu_filter: [],
      keyword_id_and: []
    }
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
