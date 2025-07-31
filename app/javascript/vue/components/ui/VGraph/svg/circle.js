export function circle({ color }, { size }) {
  const element = document.createElementNS(
    'http://www.w3.org/2000/svg',
    'circle'
  )

  element.setAttribute('fill', color)
  element.setAttribute('r', size)

  return element
}
