import Vue from 'vue'
import Vuex from 'vuex'

import { GetterFunctions } from './getters/getters'
import { MutationFunctions } from './mutations/mutations'
import { ActionFunctions } from './actions/actions'

Vue.use(Vuex)

function makeInitialState () {
  return {
    objectsForDepictions: [],
    depictionsCreated: [],
    imagesCreated: [],
    attributionsCreated: [],
    people: {
      editors: [],
      owners: [],
      authors: [],
      copyrightHolder: []
    },
    yearCopyright: undefined,
    license: undefined,
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
