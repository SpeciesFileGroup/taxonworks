export function square({ color, x, y }, { size }) {
  const element = document.createElementNS('http://www.w3.org/2000/svg', 'rect')

  element.setAttribute('width', size * 2)
  element.setAttribute('height', size * 2)
  element.setAttribute('x', -size)
  element.setAttribute('y', -size)
  element.setAttribute('fill', color)

  return element
}
