// composables/modes/useMeasureMode.js
import { ref } from 'vue'
import { svgPoint } from '../utils/svgPoint'

export function useMeasureMode(ctx) {
  const drawing = ref(false)
  const start = ref(null)
  const current = ref(null)
  const cursor = ref('crosshair')

  function onMouseDown(evt) {
    drawing.value = true
    start.value = svgPoint({ evt, ctx })
    current.value = start.value
  }

  function onMouseMove(evt) {
    if (!drawing.value) return
    current.value = svgPoint({ evt, ctx })
  }

  function onMouseUp() {
    if (!drawing.value) return

    ctx.measurements.value = [
      ...ctx.measurements.value,
      {
        x1: start.value.x,
        y1: start.value.y,
        x2: current.value.x,
        y2: current.value.y
      }
    ]

    drawing.value = false
  }

  return {
    cursor,
    drawing,
    start,
    current,
    onMouseDown,
    onMouseMove,
    onMouseUp
  }
}
