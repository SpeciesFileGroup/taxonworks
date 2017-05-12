import Vue from 'vue';
import Vuex from 'vuex';

const getters = require('./getters/getters');
const mutations = require('./mutations/mutations');

Vue.use(Vuex);

function makeInitialState() {
  return {
    taxon_name: {
      parent_id: undefined,
      name: undefined,
      rank_class: undefined,
      year_of_publication: undefined,
      verbatim_author: undefined,
      feminine_name: undefined,
      masculine_name: undefined,
      neuter_name: undefined
    },
    parent: undefined,
    ranks: undefined,
    status: [],
    allRanks: [],
  };
}

function newStore() {
  return new Vuex.Store({
    state: makeInitialState(),
    getters: getters.GetterFunctions,
    mutations: mutations.MutationFunctions
  });
}

module.exports = {
  newStore
};
