import { defineStore } from 'pinia'
import { Lead, LeadItem } from '@/routes/endpoints'
import { RouteNames } from '@/routes/routes'
import editableChildrenFields from './constants/editableChildrenFields'
import setParam from '@/helpers/setParam'

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
  // A small corner spinner - !! do not set directly !! since it's shared; use
  // store.setLoading instead.
  loading: false,
  // Ref count for loading spinner.
  loadingCount: 0,
  // Keep a copy of values from the last time a save occurred.
  last_saved: {
    origin_label: undefined,
    children: []
  },
  lead_item_otus: {
    // List of otu objects.
    parent: [],
    // Array of arrays, one for each child - each child array consists of those
    // otu indices (corresponding to the `parent` array) which are checked.
    children: []
  },
  layout: null,
  // Print version of the entire key, used only in association with lead items.
  print_key: ''
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

function editableFieldsObjectsForLeads(leads) {
  return leads.map((lead) => {
    return editableFieldsObjectForLead(lead)
  })
}

function editableFieldsObjectForLead(lead) {
  const o = {}
  editableChildrenFields.forEach((field) => {
    o[field] = lead[field]
  })

  return o
}

function differentOriginLabels(l1, l2) {
  if (!l1 && !l2) { // treat null and '' as the same
    return false
  }
  return l1 != l2
}

function childrenDifferentEditableValues(arr1, arr2) {
  let different = []
  arr1.forEach((c1, i) => {
    const c2 = arr2[i]
    if (differentEditableValues(c1, c2)) {
      different.push(c2)
    }
  })
  return different
}

function differentEditableValues(obj1, obj2) {
  for (const field of editableChildrenFields) {
    if (!obj1[field] && !obj2[field]) { // treat null and '' as the same
      continue
    }
    if (obj1[field] != obj2[field]) {
      return true
    }
  }
  return false
}

export default defineStore('leads', {
  state: makeInitialState,
  getters: {},
  actions: {
    addLead(child) {
      this.children.push(child)
      this.futures.push([])

      const last_saved_data = editableFieldsObjectForLead(child)
      this.last_saved.children.push(last_saved_data)
    },

    async loadKey(id_or_couplet) {
      let lo = undefined
      let error_message = undefined
      if (typeof(id_or_couplet) == 'object') {
        lo = id_or_couplet
      } else if (typeof(id_or_couplet) == 'number') {
        this.setLoading(true)
        try {
          lo = (await Lead.find(id_or_couplet, { extend: ['future_otus'] })).body
        }
        catch(e) {
          error_message = `Unable to load: couldn't find id ${id_or_couplet}.`
        }
        this.setLoading(false)
      } else {
        error_message = 'Unable to load: unrecognized id.'
      }

      if (error_message) {
        this.$reset()
        setParam(RouteNames.NewLead, 'lead_id')
        error_message = error_message + " You've been redirected to the New Key page."
        TW.workbench.alert.create(error_message, 'error')
        return;
      }

      this.root = lo.root
      this.lead = lo.lead
      this.children = lo.children
      this.ancestors = lo.ancestors
      this.futures = lo.futures
      this.last_saved = {
        origin_label: lo.lead.origin_label,
        children: editableFieldsObjectsForLeads(lo.children)
      }
      this.lead_item_otus = lo.lead_item_otus
      this.print_key = lo.print_key

      setParam(RouteNames.NewLead, 'lead_id', lo.lead.id)
    },

    addOtuIndex(childIndex, otuIndex, exclusive = true) {
      const payload = {
        lead_id: this.children[childIndex].id,
        otu_id: this.lead_item_otus.parent[otuIndex].id,
        exclusive // exclusive if adding this one removes all others
      }

      this.setLoading(true)
      LeadItem.addOtuIndex(payload)
        .then(({ body }) => {
          this.lead_item_otus = body.lead_item_otus
          this.print_key = body.print_key
        })
        .catch(() => {})
        .finally(() => { this.setLoading(false) })
    },

    dataChangedSinceLastSave() {
      if (
        this.children.length > 0 && (
          this.originLabelChangedSinceLastSave(this) ||
          this.childrenChangedSinceLastSaveList(this).length > 0
        )
      ) {
        return true
      }
      return false
    },

    deleteChild(child_id) {
      this.children.splice(child_id, 1)
      this.futures.splice(child_id, 1)
      this.last_saved.children.splice(child_id, 1)
    },

    removeOtuIndex(childIndex, otuIndex) {
      const payload = {
        lead_id: this.children[childIndex].id,
        otu_id: this.lead_item_otus.parent[otuIndex].id,
      }

      this.setLoading(true)
      LeadItem.removeOtuIndex(payload)
        .then(({ body }) => {
          this.lead_item_otus = body.lead_item_otus
          this.print_key = body.print_key
        })
        .catch(() => {})
        .finally(() => { this.setLoading(false) })
    },

    resetChildren(children, futures, leadItemOtus) {
      this.children = children
      this.futures = futures
      this.lead_item_otus = leadItemOtus
      this.last_saved.children = children.map((lead) => {
        return editableFieldsObjectForLead(lead)
      })
    },

    setLoading(bool) {
      if (bool == true) {
        this.loadingCount += 1
        this.loading = true
      } else {
        this.loadingCount -= 1
        if (this.loadingCount == 0) {
          this.loading = false
        }
      }
    },

    updateChild(child, future) {
      const position = child.position
      this.children[position] = child
      this.futures[position] = future

      const last_saved_data = editableFieldsObjectForLead(this.children[position])
      this.last_saved.children[position] = last_saved_data
    },

    childrenChangedSinceLastSaveList() {
      return childrenDifferentEditableValues(
        this.last_saved.children, this.children
      )
    },

    originLabelChangedSinceLastSave() {
      return differentOriginLabels(
        this.last_saved.origin_label,
        this.lead.origin_label
      )
    },
  }
})

