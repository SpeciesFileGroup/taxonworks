import Vue from 'vue'
import Vuex from 'vuex'

import { GetterFunctions } from './getters/getters'
import { MutationFunctions } from './mutations/mutations'
import { ActionFunctions } from './actions/actions'

import SledImage from '../const/sledImage'

Vue.use(Vuex)

function makeInitialState () {
  return {
    collection_object: {
      id: undefined,
      total: 1, 
      collecting_event_id: undefined,
      repository_id: undefined,
      identifiers_attributes: [],
      notes_attributes: [],
      tags_attributes: [],
      data_attributes_attributes: [],
      taxon_determinations_attributes: []
    },
    sled_image: SledImage(),
    identifier: {
      id: undefined,
      namespace_id: undefined,
      label: undefined,
      identifier: undefined,
      type: "Identifier::Local::CatalogNumber",
      identifier_object_id: undefined,
      identifier_object_type: 'CollectionObject'
    },
    image: undefined,
    navigation: {
      previous: undefined,
      next: undefined
    }
  }
}

function newStore () {
  return new Vuex.Store({
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
