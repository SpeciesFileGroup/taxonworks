import { REGION_HEADER_H, itemAABB, unionBounds } from './geometry.js'
import { clipPathShapes } from './svg.js'

const SVG_NS = 'http://www.w3.org/2000/svg'
const MARGIN = 48
const MAX_PNG_SIDE = 8192
const MAX_PIXEL_RATIO = 4
const JPEG_QUALITY = 0.9
const PARALLEL_FETCHES = 6
const FONT_SIZE = 12
const LABEL_GAP = 8
const LABEL_PAD_X = 8
const LABEL_H = 20
const COUNT_PAD_X = 8
const COUNT_H = 16

const COLORS = {
  background: '#ffffff',
  card: '#ffffff',
  cardBorder: '#d0d7de',
  placeholder: '#e6e9ed',
  text: '#1f2328',
  labelBg: '#1f2328',
  labelText: '#ffffff',
  countBg: '#eef1f4'
}

function escapeXml(value) {
  return String(value)
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
}

function createTextMeasurer(fontFamily) {
  const ctx = document.createElement('canvas').getContext('2d')

  return (text, weight = 400) => {
    ctx.font = `${weight} ${FONT_SIZE}px ${fontFamily}`

    return ctx.measureText(text).width
  }
}

function truncate(text, maxWidth, measure, weight) {
  if (measure(text, weight) <= maxWidth) return text

  let out = text

  while (out.length > 1 && measure(`${out}…`, weight) > maxWidth) {
    out = out.slice(0, -1)
  }

  return `${out}…`
}

function blobToDataUrl(blob) {
  return new Promise((resolve, reject) => {
    const reader = new FileReader()

    reader.addEventListener('load', () => resolve(reader.result))
    reader.addEventListener('error', reject)
    reader.readAsDataURL(blob)
  })
}

async function inlineSources(items) {
  const sources = [...new Set(items.map((it) => it.src).filter(Boolean))]
  const dataUrls = new Map()

  for (let i = 0; i < sources.length; i += PARALLEL_FETCHES) {
    await Promise.all(
      sources.slice(i, i + PARALLEL_FETCHES).map(async (src) => {
        try {
          const response = await fetch(src, { credentials: 'same-origin' })

          if (!response.ok) throw new Error(response.statusText)
          dataUrls.set(src, await blobToDataUrl(await response.blob()))
        } catch {
          dataUrls.set(src, null)
        }
      })
    )
  }

  return dataUrls
}

function regionSvg({ area, color, name, count }, measure) {
  const countText = String(count)
  const countW = measure(countText, 600) + COUNT_PAD_X * 2
  const nameMaxW = area.w - countW - LABEL_PAD_X * 3
  const textY = area.y + REGION_HEADER_H / 2 + 1

  return [
    `<rect x="${area.x}" y="${area.y}" width="${area.w}" height="${area.h}" rx="4" fill="${color}" fill-opacity="0.06" stroke="${color}" stroke-width="2" stroke-dasharray="6 4"/>`,
    `<rect x="${area.x}" y="${area.y}" width="${area.w}" height="${REGION_HEADER_H}" fill="${COLORS.card}"/>`,
    `<rect x="${area.x}" y="${area.y}" width="${area.w}" height="${REGION_HEADER_H}" fill="${color}" fill-opacity="0.22"/>`,
    `<rect x="${area.x}" y="${area.y}" width="${area.w}" height="3" fill="${color}"/>`,
    `<text x="${area.x + LABEL_PAD_X}" y="${textY}" font-weight="600" fill="${COLORS.text}" dominant-baseline="middle">${escapeXml(truncate(name, nameMaxW, measure, 600))}</text>`,
    `<rect x="${area.x + area.w - LABEL_PAD_X - countW}" y="${textY - COUNT_H / 2}" width="${countW}" height="${COUNT_H}" rx="${COUNT_H / 2}" fill="${COLORS.countBg}"/>`,
    `<text x="${area.x + area.w - LABEL_PAD_X - countW / 2}" y="${textY}" font-weight="600" fill="${COLORS.text}" text-anchor="middle" dominant-baseline="middle">${countText}</text>`
  ].join('')
}

function itemSvg(item, index, dataUrl, measure) {
  const w = item.w * item.scale
  const h = item.h * item.scale
  const hasMediaSize = !!(item.mediaWidth && item.mediaHeight)
  const viewBox =
    item.viewBox ||
    (hasMediaSize ? `0 0 ${item.mediaWidth} ${item.mediaHeight}` : `0 0 ${w} ${h}`)
  const clipShapes = hasMediaSize ? clipPathShapes(item.clipPath) : ''
  const clipId = `lt-export-clip-${index}`
  const parts = [
    `<g transform="translate(${item.x} ${item.y}) rotate(${item.rotation})" opacity="${item.opacity}">`,
    `<rect x="${-w / 2}" y="${-h / 2}" width="${w}" height="${h}" fill="${COLORS.card}" stroke="${COLORS.cardBorder}" stroke-width="1"/>`
  ]

  if (dataUrl) {
    parts.push(
      `<svg x="${-w / 2}" y="${-h / 2}" width="${w}" height="${h}" viewBox="${escapeXml(viewBox)}" preserveAspectRatio="xMidYMid meet">`,
      clipShapes ? `<defs><clipPath id="${clipId}">${clipShapes}</clipPath></defs>` : '',
      `<image href="${dataUrl}" x="0" y="0"`,
      hasMediaSize
        ? ` width="${item.mediaWidth}" height="${item.mediaHeight}"`
        : ` width="${w}" height="${h}" preserveAspectRatio="xMidYMid meet"`,
      clipShapes ? ` clip-path="url(#${clipId})"` : '',
      '/></svg>'
    )
  } else {
    parts.push(
      `<rect x="${-w / 2}" y="${-h / 2}" width="${w}" height="${h}" fill="${COLORS.placeholder}"/>`
    )
  }

  if (item.label) {
    const text = truncate(item.label, w * 0.9 - LABEL_PAD_X * 2, measure)
    const labelW = measure(text) + LABEL_PAD_X * 2
    const labelY = h / 2 + LABEL_GAP

    parts.push(
      `<rect x="${-labelW / 2}" y="${labelY}" width="${labelW}" height="${LABEL_H}" rx="4" fill="${COLORS.labelBg}"/>`,
      `<text x="0" y="${labelY + LABEL_H / 2 + 1}" fill="${COLORS.labelText}" text-anchor="middle" dominant-baseline="middle">${escapeXml(text)}</text>`
    )
  }

  parts.push('</g>')

  return parts.join('')
}

function exportBounds(items, regions) {
  const boxes = [
    ...items.map((it) => {
      const b = itemAABB(it)

      return it.label ? { ...b, h: b.h + LABEL_GAP + LABEL_H } : b
    }),
    ...regions.map((r) => r.area)
  ].filter(Boolean)
  const bounds = unionBounds(boxes)

  if (!bounds) return null

  return {
    x: bounds.x - MARGIN,
    y: bounds.y - MARGIN,
    w: bounds.w + MARGIN * 2,
    h: bounds.h + MARGIN * 2
  }
}

export async function layoutToSvg({ items, regions }) {
  const visible = items.filter((it) => it.x != null && it.y != null)
  const bounds = exportBounds(visible, regions)

  if (!bounds) return null

  const fontFamily = getComputedStyle(document.body).fontFamily
  const measure = createTextMeasurer(fontFamily)
  const dataUrls = await inlineSources(visible)
  const failed = visible.filter((it) => !dataUrls.get(it.src)).length
  const body = [
    ...regions.filter((r) => r.area).map((r) => regionSvg(r, measure)),
    ...[...visible]
      .sort((a, b) => a.z - b.z)
      .map((it, i) => itemSvg(it, i, dataUrls.get(it.src), measure))
  ].join('')

  const svg = [
    `<svg xmlns="${SVG_NS}" width="${bounds.w}" height="${bounds.h}" viewBox="${bounds.x} ${bounds.y} ${bounds.w} ${bounds.h}" font-family="${escapeXml(fontFamily)}" font-size="${FONT_SIZE}">`,
    `<rect x="${bounds.x}" y="${bounds.y}" width="${bounds.w}" height="${bounds.h}" fill="${COLORS.background}"/>`,
    body,
    '</svg>'
  ].join('')

  return { svg, width: bounds.w, height: bounds.h, failed }
}

function loadImage(url) {
  return new Promise((resolve, reject) => {
    const img = new Image()

    img.onload = () => resolve(img)
    img.onerror = reject
    img.src = url
  })
}

export async function svgToRasterBlob(
  { svg, width, height },
  { type = 'image/png', quality = JPEG_QUALITY } = {}
) {
  const ratio = Math.min(
    MAX_PIXEL_RATIO,
    MAX_PNG_SIDE / Math.max(width, height)
  )
  const canvas = document.createElement('canvas')
  const url = URL.createObjectURL(
    new Blob([svg], { type: 'image/svg+xml;charset=utf-8' })
  )

  canvas.width = Math.round(width * ratio)
  canvas.height = Math.round(height * ratio)

  try {
    const img = await loadImage(url)

    canvas.getContext('2d').drawImage(img, 0, 0, canvas.width, canvas.height)
  } finally {
    URL.revokeObjectURL(url)
  }

  return new Promise((resolve, reject) => {
    canvas.toBlob(
      (blob) => (blob ? resolve(blob) : reject(new Error('Image export failed'))),
      type,
      quality
    )
  })
}
