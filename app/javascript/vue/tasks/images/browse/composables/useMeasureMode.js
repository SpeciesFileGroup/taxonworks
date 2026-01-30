import { computed, ref } from 'vue'
import { svgPoint } from '../utils/svgPoint'
import MeasurementBar from '../components/Viewer/Measurement/MeasurementBar.vue'

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

  const overlayProps = computed(() => {
    if (!drawing.value || !start.value || !current.value) return null

    return {
      x1: start.value.x,
      y1: start.value.y,
      x2: current.value.x,
      y2: current.value.y,
      pixelsToCentimeters: ctx.pixelsToCentimeters.value,
      fontSize: 12 / ctx.zoom.value,
      strokeWidth: 2
    }
  })

  function onKeyDown(e) {
    if ((e.ctrlKey || e.metaKey) && e.key === 'z') {
      e.preventDefault()

      ctx.measurements.value = ctx.measurements.value.slice(0, -1)
    }

    if (e.key === 'Escape') {
      drawing.value = false
    }
  }

  return {
    cursor,
    drawing,
    start,
    current,
    onMouseDown,
    onMouseMove,
    onMouseUp,
    onKeyDown,

    overlay: MeasurementBar,
    overlayProps
  }
}
