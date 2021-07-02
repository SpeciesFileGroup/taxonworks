import { createStore } from 'vuex'
import { ActionFunctions } from '../store/actions/actions'
import { GetterFunctions } from '../store/getters/getters'
import { MutationFunctions } from '../store/mutations/mutations'

import makeExtract from '../const/makeExtract'

const makeInitialState = () => {
  return {
    settings: {
      isLoading: false,
      lock: {
        made: false,
        identifiers: false,
        lock: false,
        originRelationship: false,
        protocols: false,
        repository: false
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
    originRelationship: {},
    recents: [],
    protocols: [],
    repository: undefined,
    softValidation: []
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
  newStore,
  makeInitialState
}
