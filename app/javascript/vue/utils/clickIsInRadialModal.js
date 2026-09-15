export function clickIsInRadialModal(e) {
  const containerSelector = '.modal-container'
  const radialSvgSelector = 'svg.svg-radial-menu'

  // All radials (annotator, object, navigation) teleport their content into a
  // `.radial-annotator` wrapper on the body. Anything arising from a radial
  // (its own modal, the "All tasks" modal, destroy confirmation, nested quick
  // forms, ...) lives inside that wrapper, whether or not a radial menu SVG is
  // currently rendered.
  const radialWrapperSelector = '.radial-annotator'

  let node = e.target
  if (node && node.nodeType === Node.TEXT_NODE) {
    node = node.parentNode
  }

  if (!(node instanceof Element)) return false

  if (node.closest(radialWrapperSelector)) return true

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
