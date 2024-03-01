function leadId(lead) {
  const id =
    lead.origin_label ? '[' + lead.origin_label + ']' : '[tw:' + lead.id + ']'
  return '<b>' + id + '</b> '
}

function leadText(lead) {
  if (lead.text) {
    return lead.text.slice(0, 38) + (lead.text.length > 38 ? '...' : '')
  } else {
    return '<i>(No text)</i>'
  }
}

function marginForDepth(depth) {
  const pxs = depth * 5
  return 'margin-left: ' + pxs.toString() + 'px'
}

export { leadId, leadText, marginForDepth }