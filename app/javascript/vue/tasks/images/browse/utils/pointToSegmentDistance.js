export function pointToSegmentDistance(px, py, x1, y1, x2, y2) {
  const dx = x2 - x1
  const dy = y2 - y1

  if (dx === 0 && dy === 0) {
    return Math.hypot(px - x1, py - y1)
  }

  const t = ((px - x1) * dx + (py - y1) * dy) / (dx * dx + dy * dy)

  const clamped = Math.max(0, Math.min(1, t))

  const cx = x1 + clamped * dx
  const cy = y1 + clamped * dy

  return Math.hypot(px - cx, py - cy)
}
