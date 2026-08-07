export function pentagon({ color }, { size }) {
  const element = document.createElementNS(
    'http://www.w3.org/2000/svg',
    'polygon'
  )

  element.setAttribute('points', points(size))
  element.setAttribute('width', size)
  element.setAttribute('height', size)
  element.setAttribute('fill', color)
  element.setAttribute(
    'transform',
    `rotate(18, ${size / 2}, ${size / 2}) translate(-${size / 2}, -${size / 2})`
  )

  return element
}

function points(size) {
  return [...Array(6)]
    .map((_, i) => {
      const angleDeg = 72 * i - 36
      const angleRad = (Math.PI / 180) * angleDeg

      return [
        size / 1.8 + size * Math.cos(angleRad),
        size / 1.8 + size * Math.sin(angleRad)
      ]
    })
    .map((p) => p.join(','))
    .join(' ')
}
