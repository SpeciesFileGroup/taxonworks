import { defineStore } from 'pinia'
import { GetterFunctions } from './getters/getters'
import { ActionFunctions } from './actions/actions'

const makeInitialState = () => ({
  settings: {
    lock: {
      collectingEvent: false,
      otu: false,
      namespace: false,
      preparationTypeId: false,
      total: false
    },
    increment: false
  },
  createdIdentifiers: [],
  createdCO: undefined,
  createdCE: undefined,
  preparationTypeId: undefined,
  collectingEvent: {
    verbatim_label: undefined,
    verbatim_locality: undefined
  },
  geographicArea: undefined,
  identifier: undefined,
  namespace: undefined,
  otu: undefined,
  total: 1,
  recentList: [],
  createTotal: 1,
  pixelsToCm: undefined
})

export const useStore = defineStore('main', {
  state: makeInitialState,
  getters: GetterFunctions,
  actions: ActionFunctions
})
