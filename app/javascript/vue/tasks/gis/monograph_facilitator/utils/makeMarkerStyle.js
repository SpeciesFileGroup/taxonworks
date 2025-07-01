export function makeMarkerStyle({ color, isSelected }) {
  const element = document.createElement('div')
  const style = {
    width: '8px',
    height: '8px',
    backgroundColor: color,
    color
  }

  if (isSelected) {
    Object.assign(style, {
      border: '1px solid var(--text-color)',
      animation: 'pulse-marker 1s infinite ease-in-out'
    })
  }

  Object.assign(element.style, style)

  return {
    className: '',
    iconSize: [8, 8],
    iconAnchor: [4, 4],
    html: element
  }
}
