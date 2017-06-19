import Vue from 'vue';
import Vuex from 'vuex';

const getters = require('./getters/getters');
const mutations = require('./mutations/mutations');

Vue.use(Vuex);

function makeInitialState() {
  return {
    selected: {
      otu: undefined,
      source: undefined,
      citation: undefined,
      topics: []
    },
    topics: [],
    citations: [],
    source_citations: [],
    otu_citations: []
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
