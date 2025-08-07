import { defineStore } from 'pinia'
import { Lead, LeadItem } from '@/routes/endpoints'
import { RouteNames } from '@/routes/routes'
import { LAYOUTS } from '../shared/layouts'
import editableChildrenFields from './constants/editableChildrenFields'
import setParam from '@/helpers/setParam'
import { EXTEND } from '../shared/constants'

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
  // Which layout to display.
  layout: null,
  // Used only for full_key layout.
  key_metadata: null,
  // Ruby creates the metadata keys in dept-first search order, but javascript
  // orders numeric hash-keys, so we need this separate array (of the original
  // ruby key_metadata lead id keys) to get the order right.
  key_ordered_parents: null,
  // Used only for full_key layout.
  key_data: null,
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
    async loadKey(id_or_couplet, new_layout = null) {
      let lo = undefined
      let error_message = undefined
      if (typeof(id_or_couplet) == 'object') {
        lo = id_or_couplet
      } else if (
        typeof(id_or_couplet) == 'number' || typeof(id_or_couplet) == 'string'
      ) {
        id_or_couplet = parseInt(id_or_couplet)
        const layout_for_new_data = new_layout || this.layout
        const extend = this.extend(EXTEND.All, layout_for_new_data)

        this.setLoading(true)
        try {
          lo = (await Lead.find(id_or_couplet, { extend })).body
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
      this.last_saved = {
        origin_label: lo.lead.origin_label,
        children: editableFieldsObjectsForLeads(lo.children)
      }
      this.lead_item_otus = lo.lead_item_otus

      // Make sure new data is in place before you change the value of this.layout.
      if (!!new_layout) {
        if (new_layout == LAYOUTS.FullKey) {
          this.key_metadata = lo.key_metadata
          this.key_ordered_parents = lo.key_ordered_parents
          this.key_data = lo.key_data

          this.layout = new_layout

          this.ancestors = null
          this.futures = null
        } else {
          this.ancestors = lo.ancestors
          this.futures = lo.futures

          this.layout = new_layout

          this.key_metadata = null
          this.key_ordered_parents = null
          this.key_data = null
        }
      } else {
        this.ancestors = lo.ancestors
        this.futures = lo.futures
        this.key_metadata = lo.key_metadata
        this.key_ordered_parents = lo.key_ordered_parents
        this.key_data = lo.key_data
      }

      setParam(RouteNames.NewLead, 'lead_id', lo.lead.id)
    },

    addOtuIndex(childIndex, otuIndex, exclusive = true) {
      const extend = this.layout == LAYOUTS.FullKey ? ['key_data'] : ['future_data']
      const payload = {
        lead_id: this.children[childIndex].id,
        otu_id: this.lead_item_otus.parent[otuIndex].id,
        exclusive, // exclusive if adding this one removes all others
        extend,
      }

      this.setLoading(true)
      LeadItem.addOtuIndex(payload)
        .then(({ body }) => {
          this.lead_item_otus = body.lead_item_otus
          this.futures = body.futures
          this.key_metadata = body.key_metadata
          this.key_ordered_parents = body.key_ordered_parents
          this.key_data = body.key_data
        })
        .catch(() => {})
        .finally(() => { this.setLoading(false) })
    },

    removeOtuIndex(childIndex, otuIndex) {
      const extend = this.layout == LAYOUTS.FullKey ? ['key_data'] : ['future_data']
      const payload = {
        lead_id: this.children[childIndex].id,
        otu_id: this.lead_item_otus.parent[otuIndex].id,
        extend,
      }

      this.setLoading(true)
      LeadItem.removeOtuIndex(payload)
        .then(({ body }) => {
          this.lead_item_otus = body.lead_item_otus
          this.futures = body.futures
          this.key_metadata = body.key_metadata
          this.key_ordered_parents = body.key_ordered_parents
          this.key_data = body.key_data
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

    updateChild(child) {
      const position = child.position
      this.children[position] = child

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

    canCreateLeadItemsOnCurrentLead() {
      if (!!this.lead.parent_id || this.lead_item_otus.parent.length > 0) {
        return false
      }

      if (this.layout == LAYOUTS.FullKey) {
        let canCreate = false
        this.children.forEach((child) => {
          if (!this.key_metadata[child.id]) {
            canCreate = true
          }
        })

        return canCreate
      } else {
        let canCreate = false
        this.futures.forEach((future) => {
          if (future.length == 0) {
            // There exists a child that we can add lead item otus to.
            canCreate = true
          }
        })

        return canCreate
      }
    },

    leadHasChildren(child, i) {
      if (child.redirect_id) return false

      if (this.layout == LAYOUTS.FullKey) {
        return this.key_metadata[child.id] &&
          this.key_metadata[child.id].children?.length > 0
      } else {
        return this.futures[i].length > 0
      }
    },

    noGrandkids() {
      if (this.layout == LAYOUTS.FullKey) {
        this.children.forEach((child, i) => {
          if (this.leadHasChildren(child, i)) {
            return false
          }
        })

        return true
      } else {
        return this.futures.flat().length == 0
      }
    },

    extend(for_affected, for_layout = this.layout) {
      switch(for_affected) {
        case EXTEND.All:
          return for_layout == LAYOUTS.FullKey ?
            ['key_data'] : ['ancestors_data', 'future_otus']
        case EXTEND.CoupletAndFutures:
          return for_layout == LAYOUTS.FullKey ?
            ['key_data'] : ['future_otus']
        case EXTEND.CoupletAndFuture:
          return for_layout == LAYOUTS.FullKey ?
            ['key_data'] : ['future_otu']
        case EXTEND.CoupletOnly:
          return for_layout == LAYOUTS.FullKey ?
            ['key_data'] : []
        default:
          throw new Error(`Internal error: unrecognized for_affected ${for_affected}`)
      }
    },

    update_from_extended(for_affected, result) {
      switch(for_affected) {
        case EXTEND.CoupletAndFutures:
          // Doesn't replace existing store.ancestors
          this.key_data = result.key_data
          this.key_metadata = result.key_metadata
          this.key_ordered_parents = result.key_ordered_parents
          this.futures = result.futures
          break
        case EXTEND.CoupletAndFuture:
          this.key_data = result.key_data
          this.key_metadata = result.key_metadata
          this.key_ordered_parents = result.key_ordered_parents
          const position = result.lead.position
          this.futures[position] = result.future
          break
        case EXTEND.CoupletOnly:
          this.key_data = result.key_data
          this.key_metadata = result.key_metadata
          this.key_ordered_parents = result.key_ordered_parents
        default:
          throw new Error(`Internal error: unrecognized update for_affected ${for_affected}`)
      }
    }
  }
})

