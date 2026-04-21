export function clickIsInRadialModal(e) {
  const containerSelector = '.modal-container'
  const radialSvgSelector = 'svg.svg-radial-menu'

  let node = e.target
  if (node && node.nodeType === Node.TEXT_NODE) {
    node = node.parentNode
  }

  if (!(node instanceof Element)) return false

  // Look for any ancestor modal that contains a radial
  let cursor = node
  while (cursor) {
    const container = cursor.closest(containerSelector)
    if (!container) {
      return false
    }
    if (container.querySelector(radialSvgSelector)) {
      return true
    }

    cursor = container.parentElement
  }

  return false
}
