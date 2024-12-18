import { editableFieldsObjectForLead } from './loadKey.js'

export default function swapLeads(swap_data) {

  [0, 1].forEach((i) => {
    const lead = swap_data['leads'][i]
    const position = swap_data['positions'][i]
    const future = swap_data['futures'][i]

    this.children[position] = lead
    this.futures[position] = future
    this.last_saved.children[position] = editableFieldsObjectForLead(lead)
  })
}
