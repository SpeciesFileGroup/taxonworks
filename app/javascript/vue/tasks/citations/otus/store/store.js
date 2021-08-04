import { createStore } from 'vuex'
import { GetterFunctions } from './getters/getters'
import { MutationFunctions } from './mutations/mutations'

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
  return createStore({
    state: makeInitialState(),
    getters: GetterFunctions,
    mutations: MutationFunctions
  })
}

export {
  newStore
}
