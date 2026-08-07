export function makeSegmentedCircle({ segments, attributes = {} }) {
  const svgNS = 'http://www.w3.org/2000/svg'
  const svg = document.createElementNS(svgNS, 'svg')

  svg.setAttribute('viewBox', `-1 -1 2 2`)
  svg.setAttribute('style', 'transform: rotate(-90deg)')

  for (let key in attributes) {
    svg.setAttribute(key, attributes[key])
  }

  const angleStep = (2 * Math.PI) / segments.length

  segments.forEach((slice, i) => {
    const startAngle = i * angleStep
    const endAngle = (i + 1) * angleStep

    const x1 = Math.cos(startAngle)
    const y1 = Math.sin(startAngle)
    const x2 = Math.cos(endAngle)
    const y2 = Math.sin(endAngle)

    const largeArc = angleStep > Math.PI ? 1 : 0

    const path = document.createElementNS(svgNS, 'path')
    path.setAttribute(
      'd',
      `M 0 0 L ${x1} ${y1} A 1 1 0 ${largeArc} 1 ${x2} ${y2} Z`
    )

    path.setAttribute('class', slice.class)

    svg.appendChild(path)
  })

  return svg.outerHTML
}
