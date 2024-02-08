function lead_id(lead) {
  const id =
    lead.origin_label ? '[' + lead.origin_label + ']' : '[tw:' + lead.id + ']'
  return '<b>' + id + '</b> '
}

function lead_tag(lead) {
  if (lead.text) {
    return lead_id(lead) + lead.text.slice(0, 38) + (lead.text.length > 38 ? '...' : '')
  }
  else {
    return lead_id(lead) + '<i>(No text)</i>'
  }
}

function margin_for_depth(depth) {
  const pxs = depth * 5
  return 'margin-left: ' + pxs.toString() + 'px'
}

export { lead_id, lead_tag, margin_for_depth }