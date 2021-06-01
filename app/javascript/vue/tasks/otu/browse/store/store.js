import Vue from 'vue'
import Vuex from 'vuex'

import { GetterFunctions } from './getters/getters'
import { MutationFunctions } from './mutations/mutations'
import { ActionFunctions } from './actions/actions'
import componentNames from '../const/componentNames'

Vue.use(Vuex)

function makeInitialState () {
  return {
    loadState: {
      assertedDistribution: true,
      biologicalAssociations: true,
      collectionObjects: true,
      descendants: true,
      descendantsDistribution: true,
      distribution: true,
    },
    preferences: {
      preferenceSchema: 20200807,
      sections: Object.keys(componentNames()),
      filterSections: {
        and: {
          current: [
            {
              label: 'Current name',
              key: 'history-is-current-target',
              value: false,
              equal: true
            }
          ],
          time: [
            {
              label: 'First',
              key: 'history-is-first',
              value: false,
              equal: true
            },
            {
              label: 'Last',
              key: 'history-is-last',
              value: false,
              equal: true
            }
          ],
          year: [{
            label: 'Year',
            key: 'history-year',
            value: undefined,
            attribute: true,
            equal: true
          }]
        },
        or: {
          valid: [
            {
              label: 'Valid',
              key: 'history-is-valid',
              value: false,
              equal: true
            },
            {
              label: 'Invalid',
              key: 'history-is-valid',
              value: false,
              equal: false
            }
          ],
          cite: [
            {
              label: 'Cited',
              key: 'history-is-cited',
              value: false,
              equal: true
            },
            {
              label: 'Uncited',
              key: 'history-is-cited',
              value: false,
              equal: false
            }
          ]
        },
        show: [
          {
            label: 'Notes',
            key: 'hide-notes',
            value: false
          },
          {
            label: 'Soft validation',
            key: 'hide-validations',
            value: false
          }
        ],
        topic: [
          {
            label: 'On citations',
            key: 'hide-topics',
            value: true
          }
        ]
      }
    },
    taxonName: undefined,
    taxonNames: [],
    currentOtu: undefined,
    assertedDistributions: [],
    biologicalAssociations: [],
    collectingEvents: [],
    collectionObjects: [],
    otus: [],
    georeferences: [],
    typeMaterials: [],
    depictions: [],
    commonNames: [],
    descendants: {
      taxon_names: [],
      collecting_events: [],
      georeferences: []
    },
    observationsDepictions: [],
    userId: undefined
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
