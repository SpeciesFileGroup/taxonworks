import { createStore } from 'vuex'
import { GetterFunctions } from './getters/getters'
import { MutationFunctions } from './mutations/mutations'
import { ActionFunctions } from './actions/actions'
import makeTaxonDetermination from '../const/makeTaxonDetermination'

function makeInitialState () {
  return {
    settings: {
      saving: false,
      lock: {
        repository: false,
        taxon_determination: false,
        taxon_determinations: false
      }
    },
    collection_object: {
      preparation_type_id: undefined,
      repository_id: undefined,
      total: 1
    },
    depiction: {
      caption: ''
    },
    people: {
      authors: [],
      copyrightHolder: [],
      editors: [],
      owners: []
    },
    license: undefined,
    sqed: {
      boundary_color: undefined,
      boundary_finder: 'Sqed::BoundaryFinder::ColorLineFinder',
      has_border: false,
      id: undefined,
      layout: undefined,
      metadata_map: []
    },
    attributionsCreated: [],
    citations: [],
    data_attributes: [],
    depictionsCreated: [],
    imagesCreated: [],
    newCOForSqed: true,
    objectsForDepictions: [],
    pixels_to_centimeter: undefined,
    repository: undefined,
    source: undefined,
    tags: [],
    tagsForImage: [],
    taxonDetermination: makeTaxonDetermination(),
    taxon_determinations: [],
    yearCopyright: undefined
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
