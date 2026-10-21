export function usePointerDrag({ onStart, onMove, onEnd } = {}) {
  return function startDrag(event) {
    if (event.button !== undefined && event.button !== 0 && event.button !== 1)
      return
    const target = event.currentTarget
    target.setPointerCapture?.(event.pointerId)

    const startPoint = { x: event.clientX, y: event.clientY }
    let last = { ...startPoint }
    let cancelled = false

    const ctx = { event, start: startPoint, button: event.button }
    onStart?.(ctx)

    function handleMove(e) {
      if (cancelled) return
      const delta = { x: e.clientX - last.x, y: e.clientY - last.y }
      const total = { x: e.clientX - startPoint.x, y: e.clientY - startPoint.y }
      last = { x: e.clientX, y: e.clientY }
      onMove?.({ event: e, delta, total, start: startPoint })
    }

    function handleEnd(e) {
      cancelled = true
      target.removeEventListener('pointermove', handleMove)
      target.removeEventListener('pointerup', handleEnd)
      target.removeEventListener('pointercancel', handleEnd)
      try {
        target.releasePointerCapture?.(e.pointerId)
      } catch {}
      onEnd?.({ event: e })
    }

    target.addEventListener('pointermove', handleMove)
    target.addEventListener('pointerup', handleEnd)
    target.addEventListener('pointercancel', handleEnd)

    event.preventDefault()
    event.stopPropagation()
  }
}
