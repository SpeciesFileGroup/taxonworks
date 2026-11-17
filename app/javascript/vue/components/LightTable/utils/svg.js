const SHAPE_TAGS = [
  'path',
  'rect',
  'circle',
  'ellipse',
  'polygon',
  'polyline',
  'line'
]

export function clipPathShapes(markup) {
  if (!markup) return ''

  const doc = new DOMParser().parseFromString(
    `<svg xmlns="http://www.w3.org/2000/svg">${markup}</svg>`,
    'image/svg+xml'
  )

  if (doc.querySelector('parsererror')) return ''

  return [...doc.documentElement.querySelectorAll(SHAPE_TAGS.join(','))]
    .map((shape) => shape.outerHTML)
    .join('')
}

export function parseViewBox(viewBox) {
  if (!viewBox) return null
  const [x, y, w, h] = String(viewBox)
    .trim()
    .split(/[\s,]+/)
    .map(Number)

  if ([x, y, w, h].some((n) => Number.isNaN(n)) || !w || !h) return null

  return { x, y, w, h }
}
