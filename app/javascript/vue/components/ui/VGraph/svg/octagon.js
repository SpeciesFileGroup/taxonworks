export function octagon({ color }, { size }) {
  const element = document.createElementNS(
    'http://www.w3.org/2000/svg',
    'polygon'
  )

  element.setAttribute('points', points(size))
  element.setAttribute('width', size)
  element.setAttribute('height', size)
  element.setAttribute('fill', color)
  element.setAttribute('transform', `translate(-${size / 2}, -${size / 2})`)

  return element
}

function points(size) {
  return [...Array(9)]
    .map((_, i) => {
      const angleDeg = 45 * i - 22.5
      const angleRad = (Math.PI / 180) * angleDeg

      return [
        size / 2 + size * Math.cos(angleRad),
        size / 2 + size * Math.sin(angleRad)
      ]
    })
    .map((p) => p.join(','))
    .join(' ')
}
