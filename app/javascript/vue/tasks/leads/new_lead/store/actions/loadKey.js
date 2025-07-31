import { Lead } from '@/routes/endpoints'
import { RouteNames } from '@/routes/routes'
import editableChildrenFields from '../constants/editableChildrenFields'
import setParam from '@/helpers/setParam'

export default async function(id_or_couplet) {
  let lo = undefined
  let error_message = undefined
  if (typeof(id_or_couplet) == 'object') {
    lo = id_or_couplet
  } else if (typeof(id_or_couplet) == 'number') {
    this.loading = true
    try {
      lo = (await Lead.find(id_or_couplet, { extend: ['future_otus'] })).body
    }
    catch(e) {
      error_message = `Unable to load: couldn't find id ${id_or_couplet}.`
    }
    this.loading = false
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

  setParam(RouteNames.NewLead, 'lead_id', lo.lead.id)
}

function editableFieldsObjectsForLeads(leads) {
  return leads.map((lead) => {
    return editableFieldsObjectForLead(lead)
  })
}

export function editableFieldsObjectForLead(lead) {
  const o = {}
  editableChildrenFields.forEach((field) => {
    o[field] = lead[field]
  })

  return o
}
