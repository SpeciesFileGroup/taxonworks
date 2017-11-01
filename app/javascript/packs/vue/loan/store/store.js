import Vue from 'vue';
import Vuex from 'vuex';

import getters from './getters/getters'
import mutations from './mutations/mutations'
import actions from './actions/actions'

Vue.use(Vuex);

function makeInitialState() {
  return {
    loan: {
      date_requested: undefined,
      request_method: undefined, 
      date_sent: undefined,
      date_received: undefined,
      date_return_expected: undefined, 
      recipient_person_id: undefined, 
      recipient_address: undefined,
      recipient_email: undefined, 
      recipient_phone: undefined,
      recipient_country: undefined,
      supervisor_person_id: undefined,
      supervisor_email: undefined, 
      supervisor_phone: undefined, 
      date_closed: undefined,
      recipient_honorarium: undefined,
      lender_address: undefined,
      clone_from: undefined
    }
  }
}

function newStore() {
  return new Vuex.Store({
    state: makeInitialState(),
    getters: getters.GetterFunctions,
    mutations: mutations.MutationFunctions,
    actions: actions.ActionFunctions
  });
}

export {
  newStore
};
