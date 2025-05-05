import { editableFieldsObjectForLead } from './loadKey.js'

export default function updateChild(child, future) {
  const position = child.position
  this.children[position] = child
  this.futures[position] = future

  const last_saved_data = editableFieldsObjectForLead(this.children[position])
  this.last_saved.children[position] = last_saved_data
}
