import { reactive } from 'vue'

const MIN_ZOOM = 0.1
const MAX_ZOOM = 5

export function useViewport() {
  const state = reactive({ panX: 0, panY: 0, zoom: 1 })

  function screenToCanvas(clientX, clientY, rect) {
    return {
      x: (clientX - rect.left - state.panX) / state.zoom,
      y: (clientY - rect.top - state.panY) / state.zoom
    }
  }

  function zoomAt(clientX, clientY, factor, rect) {
    const before = screenToCanvas(clientX, clientY, rect)
    state.zoom = Math.max(MIN_ZOOM, Math.min(MAX_ZOOM, state.zoom * factor))
    const after = screenToCanvas(clientX, clientY, rect)
    state.panX += (after.x - before.x) * state.zoom
    state.panY += (after.y - before.y) * state.zoom
  }

  function pan(dx, dy) {
    state.panX += dx
    state.panY += dy
  }

  function fitBounds(bounds, rect, { padding = 60, maxZoom = 2 } = {}) {
    if (!bounds || bounds.w <= 0 || bounds.h <= 0 || !rect) return
    const availW = rect.width - padding * 2
    const availH = rect.height - padding * 2
    if (availW <= 0 || availH <= 0) return
    const z = Math.max(
      MIN_ZOOM,
      Math.min(maxZoom, MAX_ZOOM, availW / bounds.w, availH / bounds.h)
    )
    const cx = bounds.x + bounds.w / 2
    const cy = bounds.y + bounds.h / 2
    state.zoom = z
    state.panX = rect.width / 2 - cx * z
    state.panY = rect.height / 2 - cy * z
  }

  function reset() {
    state.panX = 0
    state.panY = 0
    state.zoom = 1
  }

  return { state, screenToCanvas, zoomAt, pan, fitBounds, reset }
}
