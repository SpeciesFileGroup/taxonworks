import { defineStore } from 'pinia'
import { ActionFunctions } from './actions/actions'
import editableLeftRightFields from './constants/editableLeftRightFields'

const makeInitialState = () => ({
  // The root node of the key.
  root: makeLeadObject(),
  // The currently loaded lead.
  lead : makeLeadObject(),
  // The left child of lead.
  left: makeLeadObject(),
  left_future: [],
  // The right child of lead.
  right: makeLeadObject(),
  right_future: [],
  parents: [],
  // Use this to indicate data is being retrieved, not for database changes.
  loading: false,
  // Keep a copy of values from the last time a save occurred.
  last_saved: {
    origin_label: undefined,
    left: makeSaveStateLead(),
    right: makeSaveStateLead()
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
    text: undefined
  }
}

function makeSaveStateLead() {
  const o = {}
  editableLeftRightFields.forEach((field) => {
    o[field] = undefined
  })
  return o
}
