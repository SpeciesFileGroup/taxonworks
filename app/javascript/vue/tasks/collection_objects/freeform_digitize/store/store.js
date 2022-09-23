import { createStore } from 'vuex'
import { GetterFunctions } from './getters/getters'
import { MutationFunctions } from './mutations/mutations'
import { ActionFunctions } from './actions/actions'
import SledImage from '../const/sledImage'

function makeInitialState () {
  return {
    settings: {
      lock: {
        notes_attributes: false,
        tags_attributes: false,
        repository_id: false,
        identifier: false,
        preparation_type_id: false
      }
    },
    collection_object: {
      id: undefined,
      total: 1,
      collecting_event_id: undefined,
      repository_id: undefined,
      preparation_type_id: undefined,
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
      type: 'Identifier::Local::CatalogNumber',
      identifier_object_id: undefined,
      identifier_object_type: 'CollectionObject'
    },
    image: undefined,
    navigation: {
      previous: undefined,
      next: undefined
    },
    depiction: {
      is_metadata_depiction: undefined
    },
    SVGBoard: null
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
