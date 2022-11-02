import { createStore } from 'vuex'
import { ActionFunctions } from './actions/actions'
import { GetterFunctions } from './getters/getters'
import { MutationFunctions } from './mutations/mutations'

const makeInitialState = () => {
  return {
    collectingEvent: {},
    collectionObject: {},
    container: {},
    depictions: [],
    determinations: [],
    dwc: {},
    georeferences: [],
    geographicArea: {},
    identifiers: {},
    isLoading: false,
    softValidations: [],
    timeline: {},
    biocurations: {},
    navigation: {},
    biologicalAssociations: []
  }
}

const newStore = () =>
  createStore({
    state: makeInitialState(),
    getters: GetterFunctions,
    mutations: MutationFunctions,
    actions: ActionFunctions
  })

export {
  newStore,
  makeInitialState
}
