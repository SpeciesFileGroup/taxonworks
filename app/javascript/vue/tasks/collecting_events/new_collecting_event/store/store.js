import makeCollectingEvent from '../const/makeCollectingEvent'
import makeLabel from '../const/makeLabel'
import makeTripIdentifier from '../const/makeTripIdentifier'

import { createStore } from 'vuex'
import { ActionFunctions } from './actions/actions'
import { GetterFunctions } from './getters/getters'
import { MutationFunctions } from './mutations/mutations'

const makeInitialState = () => {
  return {
    settings: {
      isLoading: false,
      isSaving: false,
      lastChange: 0,
      lastSave: 0
    },
    collectingEvent: makeCollectingEvent(),
    ceLabel: makeLabel(),
    geographicArea: undefined,
    georeferences: [],
    tripCode: makeTripIdentifier(),
    softValidations: {},
    queueGeoreferences: []
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
