import { createStore } from 'vuex'
import { ActionFunctions } from './actions/actions'
import { GetterFunctions } from './getters/getters'
import { MutationFunctions } from './mutations/mutations'

const makeInitialState = () => {
  return {
    biocurations: {},
    biologicalAssociations: [],
    collectingEvent: {},
    collectionObject: {},
    container: {},
    currentRepository: {},
    depictions: [],
    determinations: [],
    dwc: {},
    geographicArea: {},
    georeferences: [],
    identifiers: {},
    isLoading: false,
    navigation: {},
    repository: {},
    softValidations: [],
    timeline: {}
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
