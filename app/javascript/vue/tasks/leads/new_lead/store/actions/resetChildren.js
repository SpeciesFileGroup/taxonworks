import { editableFieldsObjectForLead } from './loadKey.js'

export default function resetChildren(children, futures, leadItemOtus) {
  this.children = children
  this.futures = futures
  this.lead_item_otus = leadItemOtus
  this.last_saved.children = children.map((lead) => {
    return editableFieldsObjectForLead(lead)
  })
}
