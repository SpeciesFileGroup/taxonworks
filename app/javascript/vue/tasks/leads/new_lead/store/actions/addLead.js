import { editableFieldsObjectForLead } from "./loadKey.js"

export default function(child) {
  this.children.push(child)
  this.futures.push([])

  const last_saved_data = editableFieldsObjectForLead(child)
  this.last_saved.children.push(last_saved_data)
}
