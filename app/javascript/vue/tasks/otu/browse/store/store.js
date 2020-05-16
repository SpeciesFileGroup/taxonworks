import Vue from 'vue'
import Vuex from 'vuex'

import { GetterFunctions } from './getters/getters'
import { MutationFunctions } from './mutations/mutations'
import { ActionFunctions } from './actions/actions'

Vue.use(Vuex)

function makeInitialState () {
  return {
    preferences: {
      sections: [
        'NomenclatureHistory',
        'Descendants',
        'ImageGallery',
        'CommonNames',
        'TypeSpecimens',
        'CollectionObjects',
        'ContentComponent',
        'AssertedDistribution',
        'BiologicalAssociations',
        'AnnotationsComponent',
        'CollectingEvents'
      ],
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
            key: '.history__citation_notes',
            value: false
          },
          {
            label: 'Soft validation',
            key: '.soft_validation_anchor',
            value: false
          }
        ],
        topic: [
          {
            label: 'On citations',
            key: '.history__citation_topics',
            value: true
          }
        ]
      }
    },
    currentOtu: undefined,
    assertedDistributions: [],
    collectingEvents: [],
    collectionObjects: [],
    otus: [],
    georeferences: [],
    typeMaterials: [],
    descendants: [],
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
  newStore
}
