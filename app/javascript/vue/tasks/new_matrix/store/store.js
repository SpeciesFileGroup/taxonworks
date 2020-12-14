import Vue from 'vue'
import Vuex from 'vuex'

import { GetterFunctions } from './getters/getters'
import { MutationFunctions } from './mutations/mutations'
import { ActionFunctions } from './actions/actions'

Vue.use(Vuex)

function makeInitialState () {
  return {
    settings: {
      loadingRows: false,
      loadingColumns: false,
      sortable: false
    },
    configParams: {
      per: 500
    },
    matrix: {
      id: undefined,
      name: undefined,
      project_id: undefined,
      global_id: undefined
    },
    columnFixedPagination: undefined,
    rowFixedPagination: undefined,
    matrixView: 'row',
    matrixMode: 'fixed',
    matrixRowItems: [],
    matrixColumnItems: [],
    matrixRowDynamicItems: [],
    matrixColumnDynamicItems: []
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
