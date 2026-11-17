export const REGION_HEADER_H = 26
export const REGION_PAD = 20
export const REGION_EMPTY_W = 320
export const REGION_EMPTY_H = 240

export function itemAABB(item) {
  const w = item.w * item.scale
  const h = item.h * item.scale
  const rad = (item.rotation * Math.PI) / 180
  const cos = Math.abs(Math.cos(rad))
  const sin = Math.abs(Math.sin(rad))
  const aw = w * cos + h * sin
  const ah = w * sin + h * cos

  return {
    x: item.x - aw / 2,
    y: item.y - ah / 2,
    w: aw,
    h: ah
  }
}

export function unionBounds(boxes) {
  if (!boxes.length) return null

  let minX = Infinity
  let minY = Infinity
  let maxX = -Infinity
  let maxY = -Infinity

  for (const b of boxes) {
    if (b.x < minX) minX = b.x
    if (b.y < minY) minY = b.y
    if (b.x + b.w > maxX) maxX = b.x + b.w
    if (b.y + b.h > maxY) maxY = b.y + b.h
  }

  return { x: minX, y: minY, w: maxX - minX, h: maxY - minY }
}

export function pointInArea(x, y, area) {
  if (!area) return false

  return (
    x >= area.x && x <= area.x + area.w && y >= area.y && y <= area.y + area.h
  )
}

export function gridDimsForCount(n, aspect = 4 / 3) {
  const m = Math.max(1, n)
  const cols = Math.max(1, Math.round(Math.sqrt(m * aspect)))
  const rows = Math.ceil(m / cols)

  return { cols, rows }
}

export function regionAreaFor(region, members) {
  const bounds = unionBounds(members.map(itemAABB))

  if (!bounds) {
    return {
      x: region.x,
      y: region.y,
      w: REGION_EMPTY_W,
      h: REGION_EMPTY_H
    }
  }

  return {
    x: bounds.x - REGION_PAD,
    y: bounds.y - REGION_PAD - REGION_HEADER_H,
    w: bounds.w + REGION_PAD * 2,
    h: bounds.h + REGION_PAD * 2 + REGION_HEADER_H
  }
}

export function fitSize(w, h, maxWidth) {
  if (!w || !h) return null
  const factor = w > maxWidth ? maxWidth / w : 1

  return { w: w * factor, h: h * factor }
}
