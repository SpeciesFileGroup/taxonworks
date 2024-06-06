import { createStore } from 'vuex'
import { GetterFunctions } from './getters/getters'
import { MutationFunctions } from './mutations/mutations'
import { ActionFunctions } from './actions/actions'
import componentNames from '../const/componentNames'

function makeInitialState() {
  return {
    loadState: {
      assertedDistribution: false,
      biologicalAssociations: true,
      collectingEvents: true,
      collectionObjects: true,
      descendants: false,
      descendantsDistribution: false,
      distribution: true
    },
    preferences: {
      preferenceSchema: 20231017,
      sections: Object.keys(componentNames),
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
          year: [
            {
              label: 'Year',
              key: 'history-year',
              value: undefined,
              attribute: true,
              equal: true
            }
          ]
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
    relatedBAs: [],
    collectingEvents: [],
    collectionObjects: [],
    otus: [],
    georeferences: { features: [] },
    typeMaterials: [],
    depictions: [],
    commonNames: [],
    descendants: {
      taxon_names: [],
      collecting_events: [],
      georeferences: []
    },
    observationsDepictions: [],
    userId: undefined,
    cachedMap: undefined
  }
}

function newStore() {
  return createStore({
    state: makeInitialState(),
    getters: GetterFunctions,
    mutations: MutationFunctions,
    actions: ActionFunctions
  })
}

export { newStore, makeInitialState }
