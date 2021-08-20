import { createStore } from 'vuex'
import { GetterFunctions } from './getters/getters'
import { MutationFunctions } from './mutations/mutations'
import { ActionFunctions } from './actions/actions'
import IMatrixRowCoderRequest from '../request/IMatrixRowCoderRequest'

export function makeInitialState (requestModule) {
  return {
    request: requestModule,
    taxonTitle: '',
    taxonId: null,
    matrixRow: undefined,
    description: undefined,
    descriptors: [],
    observations: [],
    confidenceLevels: null,
    units: {}
  }
}

const UnacceptableRequestModuleError = `Store must be given an IMatrixRowCoderRequest`

export function newStore (requestModule) {
  if (requestModule instanceof IMatrixRowCoderRequest === false) { throw UnacceptableRequestModuleError }

  return createStore({
    state: makeInitialState(requestModule),
    getters: GetterFunctions,
    mutations: MutationFunctions,
    actions: ActionFunctions
  })
}
