import { ref } from 'vue'

export function useMeasurements(svgRef) {
  const measurements = ref([])
  const drawing = ref(false)

  const startPoint = ref(null)
  const currentPoint = ref(null)

  function svgPoint(evt) {
    const svg = svgRef.value
    const pt = svg.createSVGPoint()
    pt.x = evt.clientX
    pt.y = evt.clientY
    return pt.matrixTransform(svg.getScreenCTM().inverse())
  }

  function startMeasurement(e) {
    drawing.value = true
    startPoint.value = svgPoint(e)
    currentPoint.value = startPoint.value
  }

  function moveMeasurement(e) {
    if (!drawing.value) return
    currentPoint.value = svgPoint(e)
  }

  function endMeasurement() {
    if (!drawing.value) return

    measurements.value.push({
      x1: startPoint.value.x,
      y1: startPoint.value.y,
      x2: currentPoint.value.x,
      y2: currentPoint.value.y
    })

    drawing.value = false
  }

  return {
    measurements,
    drawing,
    startPoint,
    currentPoint,
    startMeasurement,
    moveMeasurement,
    endMeasurement
  }
}
