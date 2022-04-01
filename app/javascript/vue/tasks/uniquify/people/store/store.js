import { GetterFunctions } from './getters/getters'
import { MutationFunctions } from './mutations/mutations'
import { ActionFunctions } from './actions/actions'
import { createStore } from 'vuex'

function makeInitialState () {
  return {
    requestState: {
      isLoading: false,
      isMerging: false
    },
    settings: {
      showMatch: true,
      showFound: true,
      showSearch: true,
      showJSONRequest: false
    },
    URLRequest: undefined,
    foundPeople: [],
    selectedPerson: {},
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
