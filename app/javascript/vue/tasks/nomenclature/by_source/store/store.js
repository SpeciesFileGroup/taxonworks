import { createStore } from 'vuex'
import { GetterFunctions } from './getters/getters'
import { MutationFunctions } from './mutations/mutations'
import { ActionFunctions } from './actions/actions'

function makeInitialState () {
  return {
    citations: {
      Otu: [],
      TaxonName: [],
      TaxonNameRelationship: [],
      TaxonNameClassification: [],
      BiologicalAssociation: [],
      AssertedDistribution: [],
    },
    otuList: [],
    paginations: {

    },
    source: {}
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
  newStore,
  makeInitialState
}
