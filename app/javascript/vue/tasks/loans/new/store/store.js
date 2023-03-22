import { createStore } from 'vuex'
import { GetterFunctions } from './getters/getters'
import { MutationFunctions } from './mutations/mutations'
import { ActionFunctions } from './actions/actions'

function makeInitialState () {
  return {
    settings: {
      loading: false,
      saving: false
    },
    loan: {
      roles_attributes: [],
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
      recipient_honorific: undefined,
      lender_address: undefined,
      clone_from: undefined
    },
    loan_items: [],
    edit_loan_items: []
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
  newStore
}
