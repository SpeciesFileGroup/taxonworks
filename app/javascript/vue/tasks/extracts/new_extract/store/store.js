import Vue from 'vue'
import Vuex from 'vuex'

Vue.use(Vuex)

const makeInitialState = () => {
  return {
    extract: {
      quantity_value,
      quantity_unit,
      concentration_value,
      concentration_unit,
      verbatim_anatomical_origin,
      year_made,
      month_made,
      day_made
    }
  }
}

function newStore () {
  return new Vuex.Store({
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
