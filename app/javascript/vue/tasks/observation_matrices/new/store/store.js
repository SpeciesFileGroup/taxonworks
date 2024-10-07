import { createStore } from 'vuex'
import { GetterFunctions } from './getters/getters'
import { MutationFunctions } from './mutations/mutations'
import { ActionFunctions } from './actions/actions'
import { MATRIX_VIEW, MATRIX_MODE } from '../const/modes.js'

function makeInitialState() {
  return {
    settings: {
      loadingRows: false,
      loadingColumns: false,
      sortable: false,
      softValidations: false
    },
    configParams: {
      per: 500
    },
    matrix: {
      id: undefined,
      name: undefined,
      otu_id: undefined,
      project_id: undefined,
      global_id: undefined
    },
    columnFixedPagination: undefined,
    rowFixedPagination: undefined,
    matrixView: MATRIX_VIEW.Row,
    matrixMode: MATRIX_MODE.Fixed,
    matrixRowItems: [],
    matrixColumnItems: [],
    matrixRowDynamicItems: [],
    matrixColumnDynamicItems: []
  }
}

export function newStore() {
  return createStore({
    state: makeInitialState(),
    getters: GetterFunctions,
    mutations: MutationFunctions,
    actions: ActionFunctions
  })
}
