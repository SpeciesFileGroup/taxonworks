import Vue from 'vue'
import Vuex from 'vuex'

import makeCollectingEvent from '../const/makeCollectingEvent'
import makeLabel from '../const/makeLabel'
import makeTripIdentifier from '../const/makeTripIdentifier'

import { ActionFunctions } from './actions/actions'
import { GetterFunctions } from './getters/getters'
import { MutationFunctions } from './mutations/mutations'

Vue.use(Vuex)

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
  new Vuex.Store({
    state: makeInitialState(),
    getters: GetterFunctions,
    mutations: MutationFunctions,
    actions: ActionFunctions
  })

export {
  newStore,
  makeInitialState
}
