import baseCRUD from './base'
import AjaxCall from '@/helpers/ajaxCall.js'

const controller = 'lead_items'
const permitParams = {
  lead_item: {
    lead_id: Number,
    otu_id: Number
  }
}

export const LeadItem = {
  ...baseCRUD(controller, permitParams),

  destroyItemInChildren: (payload) => AjaxCall(
    'post', `/${controller}/destroy_item_in_children.json`, payload
  ),

  addLeadItemToChildLead: (payload) => AjaxCall(
    'post', `/${controller}/add_lead_item_to_child_lead.json`, payload
  )
}