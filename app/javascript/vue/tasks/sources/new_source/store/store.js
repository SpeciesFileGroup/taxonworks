import Vue from 'vue'
import Vuex from 'vuex'

import { GetterFunctions } from './getters/getters'
import { MutationFunctions } from './mutations/mutations'
import { ActionFunctions } from './actions/actions'

import newSource from '../const/source'

Vue.use(Vuex)

function makeInitialState () {
  return {
    settings: {
      saving: false,
      isConverting: false,
      loading: false,
      lastSave: 0,
      lastEdit: 0,
      lock: {
        type: false,
        language_id: false,
        serial_id: false,
        bibtex_type: false
      },
      addToSource: false,
      sortable: false
    },
    preferences: {

    },
    documentations: [],
    documents: [],
    source: newSource(),
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
