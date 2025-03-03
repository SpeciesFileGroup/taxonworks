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

  destroy_item: (payload) => AjaxCall(
    'post', `/${controller}/destroy_item.json`, payload
  )
}