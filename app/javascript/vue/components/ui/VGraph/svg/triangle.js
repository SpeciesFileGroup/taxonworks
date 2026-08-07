export function triangle({ color }, { size }) {
  const element = document.createElementNS(
    'http://www.w3.org/2000/svg',
    'polygon'
  )

  element.setAttribute('fill', color)
  element.setAttribute(
    'points',
    `${0}, ${-size} -${size}, ${size} ${size}, ${size}`
  )
  return element
}
