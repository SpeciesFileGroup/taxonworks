import Vue from 'vue'
import Vuex from 'vuex'

import { GetterFunctions } from './getters/getters'
import { MutationFunctions } from './mutations/mutations'
import { ActionFunctions } from './actions/actions'

Vue.use(Vuex)

function makeInitialState () {
  return {
    settings: {
      saving: false,
      loading: false
    },
    source: {
      type: undefined,
      bibtex_type: undefined,
      verbatim: undefined,
      title: undefined,
      serial_id: undefined, 
      address: undefined,
      annote: undefined,
      author: undefined,
      booktitle: undefined,
      chapter: undefined,
      crossref: undefined,
      edition: undefined,
      editor: undefined,
      howpublished: undefined,
      institution: undefined,
      journal: undefined,
      key: undefined,
      month: undefined,
      note: undefined,
      number: undefined,
      organization: undefined,
      pages: undefined,
      publisher: undefined,
      school: undefined,
      series: undefined,
      volume: undefined,
      doi: undefined,
      abstract: undefined,
      copyright: undefined,
      language: undefined,
      stated_year: undefined,
      verbatim: undefined,
      day: undefined,
      year: undefined,
      isbn: undefined,
      issn: undefined,
      verbatim_contents: undefined,
      verbatim_keywords: undefined,
      language_id: undefined,
      translator: undefined,
      year_suffix: undefined,
      url: undefined
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
