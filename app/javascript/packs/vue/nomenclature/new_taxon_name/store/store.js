import Vue from 'vue';
import Vuex from 'vuex';

const getters = require('./getters/getters');
const mutations = require('./mutations/mutations');
const actions = require('./actions/actions');

Vue.use(Vuex);

function makeInitialState() {
  return {
    taxon_name: {
      id: undefined,
      global_id: undefined,
      parent_id: undefined,
      name: undefined,
      rank_class: undefined,
      year_of_publication: undefined,
      verbatim_author: undefined,
      feminine_name: undefined,
      masculine_name: undefined,
      neuter_name: undefined,
      source: undefined,
    },
    source: null,
    settings: {
      modalStatus: false,
      modalRelationship: false
    },
    taxonStatusList: [],
    taxonRelationshipList: [],
    taxonRelationship: undefined,
    softValidation: undefined,
    hardValidation: undefined,
    nomenclatural_code: undefined,
    parent: undefined,
    ranks: undefined,
    rankGroup: undefined,
    status: [],
    relationships: [],
    allRanks: [],
  };
}

function newStore() {
  return new Vuex.Store({
    state: makeInitialState(),
    getters: getters.GetterFunctions,
    mutations: mutations.MutationFunctions,
    actions: actions.ActionFunctions
  });
}

module.exports = {
  newStore
};
