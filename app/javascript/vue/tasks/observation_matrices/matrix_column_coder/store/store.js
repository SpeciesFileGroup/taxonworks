import { createStore } from 'vuex'
import { ActionFunctions } from './actions/actions'
import { GetterFunctions } from './getters/getters'
import { MutationFunctions } from './mutations/mutations'

const makeInitialState = () => ({
  observationColumnId: undefined,
  observationMatrix: undefined,
  descriptor: {},
  otus: [],
  collectionObjects: [],
  rowObjects: [],
  observations: [],
  units: undefined
})

const newStore = () => createStore({
  state: makeInitialState(),
  actions: ActionFunctions,
  getters: GetterFunctions,
  mutations: MutationFunctions
})

export {
  newStore,
  makeInitialState
}
