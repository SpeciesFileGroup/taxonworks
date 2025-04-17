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

  destroyItemInLeadAndDescendants: (payload) => AjaxCall(
    'post', `/${controller}/destroy_item_in_lead_and_descendants.json`, payload
  )
}