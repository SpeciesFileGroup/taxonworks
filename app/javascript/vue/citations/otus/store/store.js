import Vue from 'vue'
import Vuex from 'vuex'

import { GetterFunctions } from './getters/getters'
import { MutationFunctions } from './mutations/mutations'

Vue.use(Vuex)

function makeInitialState () {
  return {
    selected: {
      otu: undefined,
      source: undefined,
      citation: undefined,
      topics: []
    },
    topics: [],
    citations: [],
    source_citations: [],
    otu_citations: []
  }
}

function newStore () {
  return new Vuex.Store({
    state: makeInitialState(),
    getters: GetterFunctions,
    mutations: MutationFunctions
  })
}

module.exports = {
  newStore
}
