export function clickIsInRadialModal(e) {
  const containerSelector = '.modal-container'
  const radialSvgSelector = 'svg.svg-radial-menu'

  let t = e.target
  if (t && t.nodeType === Node.TEXT_NODE) {
    t = t.parentNode
  }

  if (!(t instanceof Element)) return false

  const container = t.closest(containerSelector)
  if (!container) return false

  const radial = container.querySelector(radialSvgSelector)
  return radial instanceof SVGElement
}
