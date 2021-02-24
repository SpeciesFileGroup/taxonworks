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
    collection_object: {
      total: 1,
      repository_id: undefined,
      preparation_type_id: undefined
    },
    depiction: {
      caption: ''
    },
    people: {
      editors: [],
      owners: [],
      authors: [],
      copyrightHolder: []
    },
    license: undefined,
    sqed: {
      id: undefined,
      boundary_color: undefined,
      boundary_finder: 'Sqed::BoundaryFinder::ColorLineFinder',
      has_border: false,
      layout: undefined,
      metadata_map: []
    },
    newCOForSqed: true,
    source: undefined,
    pixels_to_centimeter: undefined,
    yearCopyright: undefined,
    attributionsCreated: [],
    citations: [],
    data_attributes: [],
    depictionsCreated: [],
    imagesCreated: [],
    objectsForDepictions: [],
    tags: [],
    taxon_determinations: []
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
