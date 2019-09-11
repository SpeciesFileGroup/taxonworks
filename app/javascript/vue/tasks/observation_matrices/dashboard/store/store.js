import Vue from 'vue'
import Vuex from 'vuex'

import { GetterFunctions } from './getters/getters'
import { MutationFunctions } from './mutations/mutations'

Vue.use(Vuex)

function makeInitialState () {
  return {
    taxon: undefined,
    ranksList: [],
    rankTable: {}
  }
}

function newStore () {
  return new Vuex.Store({
    state: makeInitialState(),
    getters: GetterFunctions,
    mutations: MutationFunctions
  })
}

export {
  newStore,
  makeInitialState
}
