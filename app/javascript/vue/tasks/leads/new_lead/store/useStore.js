import { defineStore } from 'pinia'
import { ActionFunctions } from './actions/actions'

const makeInitialState = () => ({
  // The root node of the key.
  root: makeLeadObject(),
  // The currently loaded lead.
  lead : makeLeadObject(),
  // The left child of lead.
  left: makeLeadObject(),
  left_future: [],
  left_has_children: undefined,
  // The right child of lead.
  right: makeLeadObject(),
  right_future: [],
  right_has_children: undefined,
  parents: []
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