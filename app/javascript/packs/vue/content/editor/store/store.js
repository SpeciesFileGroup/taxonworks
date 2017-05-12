import Vue from 'vue';
import Vuex from 'vuex';

const getters = require('./getters/getters');
const mutations = require('./mutations/mutations');

Vue.use(Vuex);

function makeInitialState() {
    return {
        selected: {
          content: undefined,
          topic: undefined,
          otu: undefined,
        },
        recent: {
          contents: [],
          topics: [],
          otus: []
        },
        panels: {
          otu: false,
          topic: true,
          recent: true,
          figures: false,
          citations: false
        },
        depictions: [],
        citations: []
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
