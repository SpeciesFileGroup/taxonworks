export function addPatternToMap(mapElement) {
  const container = mapElement.querySelector('.leaflet-overlay-pane')

  const svg = document.createElementNS('http://www.w3.org/2000/svg', 'svg')

  svg.setAttribute('width', '0px')
  svg.setAttribute('height', '0px')
  svg.style.position = 'absolute'

  if (container.querySelector('#hatch-pattern')) return

  const pattern = document.createElementNS(
    'http://www.w3.org/2000/svg',
    'pattern'
  )

  pattern.setAttribute('id', 'hatch-pattern')
  pattern.setAttribute('patternUnits', 'userSpaceOnUse')
  pattern.setAttribute('width', '10')
  pattern.setAttribute('height', '10')

  const line = document.createElementNS('http://www.w3.org/2000/svg', 'line')
  line.setAttribute('x1', '0')
  line.setAttribute('y1', '0')
  line.setAttribute('x2', '10')
  line.setAttribute('y2', '10')
  line.setAttribute('stroke', 'var(--color-map-asserted-distribution)')
  line.setAttribute('stroke-width', '1')

  pattern.appendChild(line)

  const defs = document.createElementNS('http://www.w3.org/2000/svg', 'defs')
  defs.appendChild(pattern)
  svg.insertBefore(defs, svg.firstChild)

  container.appendChild(svg)
}
