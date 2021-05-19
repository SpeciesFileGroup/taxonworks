import Vue from 'vue'
import Vuex from 'vuex'
import { GetterFunctions } from './getters/getters'
import { MutationFunctions } from './mutations/mutations'
import { ActionFunctions } from './actions/actions'
import IMatrixRowCoderRequest from '../request/IMatrixRowCoderRequest'

Vue.use(Vuex)

export function makeInitialState (requestModule) {
  return {
    request: requestModule,
    taxonTitle: '',
    taxonId: null,
    matrixRow: undefined,
    descriptors: [],
    observations: [],
    confidenceLevels: null,
    units: {}
  }
}

const UnacceptableRequestModuleError = `Store must be given an IMatrixRowCoderRequest`

export function newStore (requestModule) {
  if (requestModule instanceof IMatrixRowCoderRequest === false) { throw UnacceptableRequestModuleError }

  return new Vuex.Store({
    state: makeInitialState(requestModule),
    getters: GetterFunctions,
    mutations: MutationFunctions,
    actions: ActionFunctions
  })
}
