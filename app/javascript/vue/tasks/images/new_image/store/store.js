import Vue from 'vue'
import Vuex from 'vuex'

import { GetterFunctions } from './getters/getters'
import { MutationFunctions } from './mutations/mutations'
import { ActionFunctions } from './actions/actions'

Vue.use(Vuex)

function makeInitialState () {
  return {
    settings: {
      saving: false
    },
    objectsForDepictions: [],
    depictionsCreated: [],
    imagesCreated: [],
    attributionsCreated: [],
    people: {
      editors: [],
      owners: [],
      authors: [],
      copyrightHolder: []
    },
    yearCopyright: undefined,
    license: undefined,
    sqed: {
      id: undefined,
      boundary_color: undefined,
      boundary_finder: 'Sqed::BoundaryFinder::ColorLineFinder',
      has_border: false, 
      layout: undefined,
      metadata_map: []
    },
    taxon_determinations: [],
    newCOForSqed: true,
    collection_object: {
      total: 1,
      repository_id: undefined,
      preparation_type_id: undefined
    },
    depiction: {
      caption: ''
    },
    source: undefined,
    citations: [],
    tags: [],
    data_attributes: []
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
