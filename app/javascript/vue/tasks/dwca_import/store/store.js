import Vue from 'vue'
import Vuex from 'vuex'

import { GetterFunctions } from './getters/getters'
import { MutationFunctions } from './mutations/mutations'
import { ActionFunctions } from './actions/actions'

Vue.use(Vuex)

function makeInitialState () {
  return {
    settings: {
      isLoading: false,
      isProcessing: false,
      retryErrored: false
    },
    paramsFilter: {
      per: 50,
      filter: {},
      status: []
    },
    temporary: {
      downloadingPages: []
    },
    startRow: undefined,
    dataset: {},
    datasetRecords: [],
    selectedRowIds: [],
    table: undefined,
    pagination: undefined,
    maxRecordsPerVirtualPage: 250000,
    currentPage: 1
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
