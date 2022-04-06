import { IDENTIFIER_LOCAL_TRIP_CODE } from 'constants/index.js'
import { createStore } from 'vuex'
import { ActionFunctions } from './actions/actions'
import { GetterFunctions } from './getters/getters'
import { MutationFunctions } from './mutations/mutations'

import makeCollectingEvent from 'factory/CollectingEvent.js'
import makeLabel from 'factory/Label'
import makeIdentifier from 'factory/Identifier.js'

const makeInitialState = () => {
  return {
    settings: {
      isLoading: false,
      isSaving: false,
      lastChange: 0,
      lastSave: 0
    },
    preferences: {
      incrementIdentifier: false
    },
    collectingEvent: makeCollectingEvent(),
    ceLabel: makeLabel('CollectingEvent'),
    geographicArea: undefined,
    georeferences: [],
    tripCode: makeIdentifier(IDENTIFIER_LOCAL_TRIP_CODE, 'CollectingEvent'),
    softValidations: {},
    queueGeoreferences: [],
    unit: 'm'
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
