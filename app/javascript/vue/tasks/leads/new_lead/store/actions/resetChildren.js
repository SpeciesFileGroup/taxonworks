import { editableFieldsObjectForLead } from './loadKey.js'

export default function resetChildren(children, futures) {
  this.children = children
  this.futures = futures
  this.last_saved.children = children.map((lead) => {
    return editableFieldsObjectForLead(lead)
  })
}
