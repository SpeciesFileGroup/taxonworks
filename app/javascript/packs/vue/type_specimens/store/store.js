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
      protonym_id: undefined,
      biological_object_id: undefined,
      type_type: undefined,
      roles_attributes: [],
      origin_citation_attributes: undefined,
    },
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
