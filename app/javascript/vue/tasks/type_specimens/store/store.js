import { GetterFunctions } from './getters/getters'
import { MutationFunctions } from './mutations/mutations'
import { ActionFunctions } from './actions/actions'
import { createStore } from 'vuex'

import Identifier from '../const/identifier'

function makeInitialState () {
  return {
    settings: {
      loading: false,
      saving: false,
      materialTab: 'new',
      saveIdentifier: false
    },
    taxon_name: undefined,
    type_material: {
      id: undefined,
      protonym_id: undefined,
      collection_object_id: undefined,
      type_type: undefined,
      roles_attributes: [],
      collection_object_attributes: {
        id: undefined,
        total: 1,
        preparation_type_id: undefined,
        repository_id: undefined,
        collecting_event_id: undefined,
        buffered_collecting_event: undefined,
        buffered_determinations: undefined,
        buffered_other_labels: undefined
      },
      origin_citation_attributes: {
        source_id: undefined,
        pages: undefined
      },
      type_designator_roles: []
    },
    identifier: Identifier(),
    type_materials: [],
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
  newStore
}
