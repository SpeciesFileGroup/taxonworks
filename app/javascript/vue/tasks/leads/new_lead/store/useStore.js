import { defineStore } from 'pinia'
import { ActionFunctions } from './actions/actions'

const makeInitialState = () => ({
  // The root node of the key.
  root: makeLeadObject(),
  // The currently loaded lead.
  lead : makeLeadObject(),
  // Children of lead.
  children: [],
  // Futures of children, indexed the same as children.
  futures: [],
  // Ancestors of lead.
  ancestors: [],
  // Use this to indicate data is being retrieved, not for database changes.
  loading: false,
  // Keep a copy of values from the last time a save occurred.
  last_saved: {
    origin_label: undefined,
    children: []
  }
})

export const useStore = defineStore('leads', {
  state: makeInitialState,
  getters: {},
  actions: ActionFunctions
})

function makeLeadObject() {
  return {
    description: undefined,
    global_id: undefined,
    id: undefined,
    is_public: undefined,
    link_out: undefined,
    link_out_text: undefined,
    origin_label: undefined,
    otu_id: undefined,
    parent_id: undefined,
    redirect_id: undefined,
    text: undefined,
    future: []
  }
}

