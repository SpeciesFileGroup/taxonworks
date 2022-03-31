import { GetterFunctions } from './getters/getters'
import { MutationFunctions } from './mutations/mutations'
import { ActionFunctions } from './actions/actions'
import { createStore } from 'vuex'

function makeInitialState () {
  return {
    settings: {
      showMatch: true,
      showFound: true,
      showSearch: true,
      showJSONRequest: false
    },
    foundPeople: [],
    selectedPerson: undefined,
    matchPeople: [],
    mergeList: [],
    mergePerson: {},
    displayCount: false
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
  newStore
}
