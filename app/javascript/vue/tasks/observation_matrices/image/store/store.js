import { createStore } from 'vuex'
import { GetterFunctions } from './getters/getters'
import { MutationFunctions } from './mutations/mutations'
import { ActionFunctions } from './actions/actions'

function makeInitialState () {
  return {
    isLoading: false,
    isSaving: false,
    languages: [],
    observationRows: [],
    observationColumns: [],
    observationMatrix: undefined,
    observations: [],
    observationMoved: undefined,
    depictionMoved: undefined,
    pagination: {}
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
  newStore
}
