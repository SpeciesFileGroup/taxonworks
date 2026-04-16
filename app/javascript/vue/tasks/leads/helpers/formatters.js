function leadText(lead) {
  if (lead.text) {
    return lead.text.slice(0, 38) + (lead.text.length > 38 ? '...' : '')
  }
  return ''
}

function marginForDepth(depth) {
  const pxs = depth * 5
  return pxs > 0 ? ('margin-left: ' + pxs.toString() + 'px') : ''
}

export { leadText, marginForDepth }
