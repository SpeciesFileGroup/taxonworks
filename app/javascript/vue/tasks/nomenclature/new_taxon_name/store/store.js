import { createStore } from 'vuex'
import { GetterFunctions } from './getters/getters'
import { MutationFunctions } from './mutations/mutations'
import { ActionFunctions } from './actions/actions'

function makeInitialState () {
  return {
    taxon_name: {
      id: undefined,
      global_id: undefined,
      parent_id: undefined,
      name: undefined,
      rank: undefined,
      rank_class: undefined,
      rank_string: undefined,
      year_of_publication: undefined,
      verbatim_author: undefined,
      feminine_name: undefined,
      masculine_name: undefined,
      neuter_name: undefined,
      origin_citation: undefined,
      taxon_name_author_roles: [],
      roles_attributes: [],
      etymology: ''
    },
    settings: {
      modalStatus: false,
      modalType: false,
      modalRelationship: false,
      saving: false,
      lastSave: 0,
      lastChange: 0,
      initLoad: false,
      autosave: true
    },
    combinationList: [],
    taxonStatusList: [],
    taxonRelationshipList: [],
    taxonRelationship: undefined,
    taxonType: undefined,
    softValidation: {
      taxon_name: {
        title: 'Taxon name',
        list: []
      },
      taxonRelationshipList: {
        title: 'Relationships',
        list: []
      },
      taxonStatusList: {
        title: 'Status',
        list: []
      },
      original_combination: {
        title: 'Original combination',
        list: [],
        transform: (value) => Object.values(value)
      }
    },
    hardValidation: undefined,
    nomenclatural_code: undefined,
    parent: undefined,
    ranks: undefined,
    rankGroup: undefined,
    status: [],
    relationships: [],
    allRanks: [],
    original_combination: []
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
  newStore
}
