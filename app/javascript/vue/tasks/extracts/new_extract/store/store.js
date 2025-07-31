import { createStore } from 'vuex'
import { ActionFunctions } from '../store/actions/actions'
import { GetterFunctions } from '../store/getters/getters'
import { MutationFunctions } from '../store/mutations/mutations'
import makeOriginRelationship from '../helpers/makeOriginRelationship'

import makeExtract from '../const/makeExtract'

const makeInitialState = () => {
  return {
    settings: {
      isLoading: false,
      lock: {
        confidences: false,
        made: false,
        lock: false,
        originRelationships: false,
        protocols: false,
        repository: false,
        roles: false
      },
      sortable: false
    },
    preferences: {
      user: undefined,
      project: undefined
    },
    extract: makeExtract(),
    identifiers: [],
    lastChange: 0,
    lastSave: 0,
    originRelationship: makeOriginRelationship(),
    originRelationships: [],
    recents: [],
    protocols: [],
    repository: undefined,
    softValidation: [],
    roles: [],
    confidences: []
  }
}

function newStore() {
  return createStore({
    state: makeInitialState(),
    getters: GetterFunctions,
    mutations: MutationFunctions,
    actions: ActionFunctions
  })
}

export { newStore, makeInitialState }
