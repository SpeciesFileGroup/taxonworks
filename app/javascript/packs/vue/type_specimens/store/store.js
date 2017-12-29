import Vue from 'vue';
import Vuex from 'vuex';

import { GetterFunctions } from './getters/getters'
import { MutationFunctions } from './mutations/mutations'
import { ActionFunctions } from './actions/actions'

Vue.use(Vuex);

function makeInitialState() {
  return {
    settings: {
      loading: false,
      saving: false
    },
    type_material: {
      id: undefined,
      protonym_id: undefined,
      biological_object_id: undefined,
      type_type: 'holotype',
      roles_attributes: [],
      origin_citation_attributes: undefined,
    },
    collection_object: {
      id: undefined,
      total: undefined,
      preparation_type_id: undefined,
      repository_id: undefined,
      collecting_event_id: undefined,
      buffered_collecting_event: undefined,
      buffered_deteriminations: undefined,
      buffered_other_labels: undefined,
    },
    type_materials: []
  }
}

function newStore() {
  return new Vuex.Store({
    state: makeInitialState(),
    getters: GetterFunctions,
    mutations: MutationFunctions,
    actions: ActionFunctions
  });
}

export {
  newStore
};
