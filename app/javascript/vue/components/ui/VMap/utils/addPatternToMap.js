export function addPatternToMap(mapElement) {
  const container = mapElement?.querySelector('.leaflet-overlay-pane')

  if (!container || container.querySelector('#hatch-pattern')) return

  const svg = document.createElementNS('http://www.w3.org/2000/svg', 'svg')

  svg.setAttribute('width', '0px')
  svg.setAttribute('height', '0px')
  svg.style.position = 'absolute'

  const pattern = document.createElementNS(
    'http://www.w3.org/2000/svg',
    'pattern'
  )

  pattern.setAttribute('id', 'hatch-pattern')
  pattern.setAttribute('patternUnits', 'userSpaceOnUse')
  pattern.setAttribute('width', '10')
  pattern.setAttribute('height', '10')

  const rect = document.createElementNS('http://www.w3.org/2000/svg', 'rect')
  rect.setAttribute('x', '0')
  rect.setAttribute('y', '0')
  rect.setAttribute('width', '10')
  rect.setAttribute('height', '10')
  rect.setAttribute('fill-opacity', '0.75')
  rect.setAttribute('fill', 'var(--color-map-asserted-distribution-absent)')

  const line = document.createElementNS('http://www.w3.org/2000/svg', 'line')
  line.setAttribute('x1', '0')
  line.setAttribute('y1', '0')
  line.setAttribute('x2', '10')
  line.setAttribute('y2', '10')
  line.setAttribute('stroke', 'var(--color-map-asserted-distribution-absent)')
  line.setAttribute('stroke-width', '2')

  pattern.appendChild(rect)
  pattern.appendChild(line)

  const defs = document.createElementNS('http://www.w3.org/2000/svg', 'defs')
  defs.appendChild(pattern)
  svg.insertBefore(defs, svg.firstChild)

  container.appendChild(svg)
}
