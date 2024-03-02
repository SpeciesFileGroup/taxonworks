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

function coupletText(lead, label) {
  const text = leadText(lead)
  if (label) {
    return '<span class="lead-super">[' + label + ']</span> ' + text
  }
  return text
}

export { marginForDepth, coupletText }
