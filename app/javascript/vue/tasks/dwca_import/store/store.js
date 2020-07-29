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
      isProcessing: false
    },
    paramsFilter: {
      filter: {},
      status: []
    },
    dataset: {},
    datasetRecords: [],
    selectedRowIds: [],
    table: undefined,
    pagination: undefined
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
