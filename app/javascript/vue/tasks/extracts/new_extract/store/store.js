import Vue from 'vue'
import Vuex from 'vuex'

import { ActionFunctions } from '../store/actions/actions'
import { GetterFunctions } from '../store/getters/getters'
import { MutationFunctions } from '../store/mutations/mutations'

import makeExtract from '../const/makeExtract'

Vue.use(Vuex)

const makeInitialState = () => {
  return {
    settings: {
      isLoading: false,
      lock: {
        date: false,
        identifiers: false,
        lock: false,
        originRelationship: false,
        protocols: false,
        repository: false
      },
      sortable: false
    },
    preferences: {
      user: undefined,
      project: undefined
    },
    extract: makeExtract(),
    identifiers: [],
    originRelationship: {},
    recents: [],
    protocols: [],
    repository: undefined,
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
