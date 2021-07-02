import { createStore } from 'vuex'
import { GetterFunctions } from './getters/getters'
import { MutationFunctions } from './mutations/mutations'

function makeInitialState () {
  return {
    taxon: undefined,
    combinations: false,
    ranksList: [],
    rankTable: {}
  }
}

function newStore () {
  return new createStore({
    state: makeInitialState(),
    getters: GetterFunctions,
    mutations: MutationFunctions
  })
}

export {
  newStore,
  makeInitialState
}
