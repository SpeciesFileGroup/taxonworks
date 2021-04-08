import Vue from 'vue'
import Vuex from 'vuex'

import { ActionFunctions } from '../store/actions/actions'
import { GetterFunctions } from '../store/getters/getters'
import { MutationFunctions } from '../store/mutations/mutations'

import makeExtract from '../const/makeExtract'
import makeOriginRelationship from '../const/makeOriginRelationship'

Vue.use(Vuex)

const makeInitialState = () => {
  return {
    settings: {
      lock: {
        date: false,
        lock: false,
        protocol: false,
        repository: false
      },
      sortable: false
    },
    preferences: {
      user: undefined,
      project: undefined
    },
    repository: undefined,
    originRelationship: makeOriginRelationship(),
    extract: makeExtract(),
    identifiers: [],
    softValidation: [],
    protocols: []
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
