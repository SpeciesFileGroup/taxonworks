import Vue from 'vue'
import Vuex from 'vuex'

import { GetterFunctions } from './getters/getters'
import { MutationFunctions } from './mutations/mutations'

Vue.use(Vuex)

function makeInitialState () {
  return {
    content: {
      otu_id: undefined,
      topic_id: undefined,
      text: undefined
    },
    selected: {
      content: undefined,
      topic: undefined,
      otu: undefined
    },
    recent: {
      contents: [],
      topics: [],
      otus: []
    },
    panels: {
      otu: false,
      topic: true,
      recent: true,
      figures: false,
      citations: false
    },
    depictions: [],
    citations: []
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
  newStore
}
