import { createStore } from 'vuex'
import { GetterFunctions } from './getters/getters'
import { MutationFunctions } from './mutations/mutations'
import { ActionFunctions } from './actions/actions'

function makeInitialState () {
  return {
    settings: {
      importModalView: false,
      isLoading: false,
      isProcessing: false,
      retryErrored: false,
      stopRequested: false,
      namespaceUpdated: false
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
    namespaces: {},
    datasetRecords: [],
    selectedRowIds: [],
    table: undefined,
    pagination: undefined,
    maxRecordsPerVirtualPage: 250000,
    currentPage: 1
  }
}

function newStore () {
  return createStore({
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
